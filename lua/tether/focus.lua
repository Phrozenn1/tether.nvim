local M = {}

---Finner banen til editor_focus.json
function M.get_file_path()
  local state_dir = vim.fn.expand("~/.local/state/tether")
  if vim.fn.isdirectory(state_dir) == 0 then
    vim.fn.mkdir(state_dir, "p")
  end
  return state_dir .. "/editor_focus.json"
end

---Lagrer editor-fokusstatus atomisk til disk
---@param focused boolean
function M.set_focused(focused)
  local data = {
    editor = "neovim",
    focused = focused,
    pid = vim.fn.getpid(),
    timestamp = os.time(),
    server_name = vim.v.servername or "",
  }
  local file_path = M.get_file_path()
  local tmp_path = file_path .. ".tmp." .. vim.fn.getpid()
  local f = io.open(tmp_path, "w")
  if f then
    f:write(vim.json.encode(data))
    f:close()
    os.rename(tmp_path, file_path)
  end
end

return M
