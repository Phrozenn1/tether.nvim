local config = require("tether.config")

local M = {}

---Finner banen til context_anchor.json
function M.get_file_path()
  local state_dir = vim.fn.expand("~/.local/state/tether")
  if vim.fn.isdirectory(state_dir) == 0 then
    vim.fn.mkdir(state_dir, "p")
  end
  return state_dir .. "/context_anchor.json"
end

---Finn rotkatalog for Git
local function get_git_root(file_path)
  local dir = file_path and vim.fn.fnamemodify(file_path, ":h") or vim.fn.getcwd()
  if vim.fs and vim.fs.root then
    local root = vim.fs.root(dir, ".git")
    if root then return root end
  end
  local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")
  if out and #out > 0 and out[1] ~= "" then
    return out[1]
  end
  return nil
end

---Finn aktiv git branch
local function get_git_branch(dir)
  local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current 2>/dev/null")
  if out and #out > 0 and out[1] ~= "" then
    return out[1]
  end
  return ""
end

---Lagrer et kontekst-anker til disk
---@param note? string Valgfri beskrivelse eller intensjon
---@return table|nil
function M.save(note)
  local cur_buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(cur_buf) then
    return nil
  end

  -- Ignorer spesielle buffere som neo-tree, telescope, etc.
  local buftype = vim.bo[cur_buf].buftype
  local cur_file = vim.api.nvim_buf_get_name(cur_buf)
  if buftype ~= "" or cur_file == "" or not vim.fn.filereadable(cur_file) then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local col = cursor[2]

  local git_root = get_git_root(cur_file)
  local project_path = git_root or vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(project_path, ":t")
  local branch = get_git_branch(project_path)

  local rel_path = cur_file
  if git_root and cur_file:sub(1, #git_root) == git_root then
    rel_path = cur_file:sub(#git_root + 2)
  else
    rel_path = vim.fn.fnamemodify(cur_file, ":.")
  end

  local anchor_data = {
    timestamp = os.time(),
    project_name = project_name,
    project_path = project_path,
    branch = branch,
    file_path = cur_file,
    relative_path = rel_path,
    line = line,
    col = col,
    last_note = note or "",
    server_name = vim.v.servername or "",
  }

  local file_path = M.get_file_path()
  local f = io.open(file_path, "w")
  if f then
    f:write(vim.json.encode(anchor_data))
    f:close()
  end

  return anchor_data
end

---Laster inn kontekst-anker fra disk
---@return table|nil
function M.load()
  local file_path = M.get_file_path()
  local f = io.open(file_path, "r")
  if not f then return nil end

  local content = f:read("*a")
  f:close()
  if not content or content == "" then return nil end

  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" and data.file_path then
    return data
  end
  return nil
end

---Gjenopptar fra forrige lagrede anker
function M.resume()
  local anchor = M.load()
  if not anchor or not anchor.file_path or anchor.file_path == "" then
    vim.notify("Ingen lagret Tether-anker funnet.", vim.log.levels.WARN, { title = "Tether Anchor" })
    return
  end

  if vim.fn.filereadable(anchor.file_path) == 0 then
    vim.notify("Anker-filen finnes ikke lenger:\n" .. anchor.file_path, vim.log.levels.WARN, { title = "Tether Anchor" })
    return
  end

  local cur_file = vim.api.nvim_buf_get_name(0)
  if cur_file ~= anchor.file_path then
    vim.cmd("edit " .. vim.fn.fnameescape(anchor.file_path))
  end

  local total_lines = vim.api.nvim_buf_line_count(0)
  local target_line = math.min(total_lines, math.max(1, anchor.line or 1))
  local target_col = math.max(0, anchor.col or 0)

  pcall(vim.api.nvim_win_set_cursor, 0, { target_line, target_col })
  vim.cmd("normal! zz")

  local msg = string.format("⚓ Gjenopptok: %s (L%d)", anchor.relative_path or anchor.file_path, target_line)
  if anchor.branch and anchor.branch ~= "" then
    msg = msg .. " [" .. anchor.branch .. "]"
  end
  if anchor.last_note and anchor.last_note ~= "" then
    msg = msg .. "\nNotat: " .. anchor.last_note
  end

  vim.notify(msg, vim.log.levels.INFO, { title = "Tether Anchor" })
end

return M
