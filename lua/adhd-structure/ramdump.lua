local config = require("adhd-structure.config")

local M = {}

---Setter inn RAM-dump malen i aktiv buffer
function M.insert()
  local opts = config.options.ramdump
  local lines = vim.deepcopy(opts.template)

  local cur_line = vim.api.nvim_win_get_cursor(0)[1]
  local total_lines = vim.api.nvim_buf_line_count(0)
  local cur_content = vim.api.nvim_get_current_line()

  -- Hvis bufferen kun inneholder én tom linje, erstatt den
  if total_lines == 1 and cur_content == "" then
    vim.api.nvim_buf_set_lines(0, 0, 1, false, lines)
    local target_line = math.min(#lines, opts.cursor_line_offset or 2)
    vim.api.nvim_win_set_cursor(0, { target_line, opts.cursor_col or 13 })
  else
    -- Sett inn linjene rett under gjeldende linje
    vim.api.nvim_buf_set_lines(0, cur_line, cur_line, false, lines)
    local target_line = cur_line + (opts.cursor_line_offset or 2)
    vim.api.nvim_win_set_cursor(0, { target_line, opts.cursor_col or 13 })
  end

  -- Start Insert Mode rett etter '[NÅ]: '
  vim.cmd("startinsert!")
end

return M
