local config = require("tether.config")

local M = {
  last_dump = nil,
}

---Setter inn RAM-dump malen i aktiv buffer
function M.insert()
  local opts = config.options.ramdump
  local lines = vim.deepcopy(opts.template)

  local cur_line = vim.api.nvim_win_get_cursor(0)[1]
  local total_lines = vim.api.nvim_buf_line_count(0)
  local cur_content = vim.api.nvim_get_current_line()
  local cur_file = vim.api.nvim_buf_get_name(0)

  local target_line
  if total_lines == 1 and cur_content == "" then
    vim.api.nvim_buf_set_lines(0, 0, 1, false, lines)
    target_line = math.min(#lines, opts.cursor_line_offset or 2)
    vim.api.nvim_win_set_cursor(0, { target_line, opts.cursor_col or 13 })
  else
    vim.api.nvim_buf_set_lines(0, cur_line, cur_line, false, lines)
    target_line = cur_line + (opts.cursor_line_offset or 2)
    vim.api.nvim_win_set_cursor(0, { target_line, opts.cursor_col or 13 })
  end

  -- Lagre state for Tether Resume (<leader>tr)
  M.last_dump = {
    file = cur_file,
    line = target_line,
    time = os.date("%H:%M:%S"),
  }

  local ok_anchor, anchor = pcall(require, "tether.anchor")
  if ok_anchor and anchor.save then
    anchor.save("RAM-dump pause")
  end

  vim.cmd("startinsert!")
end

---Gjenopptar og hopper direkte tilbake til forrige RAM-dump posisjon
function M.resume()
  if not M.last_dump or not M.last_dump.file or M.last_dump.file == "" then
    local ok_anchor, anchor = pcall(require, "tether.anchor")
    if ok_anchor and anchor.resume then
      anchor.resume()
      return
    end
    vim.notify("Ingen lagret RAM-dump posisjon funnet.", vim.log.levels.WARN, { title = "Tether Resume" })
    return
  end

  local cur_file = vim.api.nvim_buf_get_name(0)
  if cur_file ~= M.last_dump.file then
    vim.cmd("edit " .. vim.fn.fnameescape(M.last_dump.file))
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local target_line = math.min(line_count, math.max(1, M.last_dump.line or 1))
  vim.api.nvim_win_set_cursor(0, { target_line, config.options.ramdump.cursor_col or 13 })

  vim.notify(string.format("Gjenopptok fra RAM-dump kl. %s (linje %d)", M.last_dump.time, target_line), vim.log.levels.INFO, {
    title = "Tether Resume",
  })
end

return M
