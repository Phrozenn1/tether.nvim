local config = require("adhd-structure.config")

local M = {
  buf = nil,
  win = nil,
  visible = true,
}

---Oppretter eller oppdaterer highlight-grupper
function M.setup_highlights()
  local colors = config.options.hud.colors

  -- Grønn ramme for fokus
  vim.api.nvim_set_hl(0, "AdhdFocusBorder", {
    fg = colors.focus_border,
    default = true,
  })
  vim.api.nvim_set_hl(0, "AdhdFocusTitle", {
    fg = colors.focus_fg,
    bold = true,
    default = true,
  })
  vim.api.nvim_set_hl(0, "AdhdFocusText", {
    fg = colors.focus_fg,
    bold = true,
    default = true,
  })

  -- Rød ramme for pause
  vim.api.nvim_set_hl(0, "AdhdBreakBorder", {
    fg = colors.rest_border,
    default = true,
  })
  vim.api.nvim_set_hl(0, "AdhdBreakTitle", {
    fg = colors.rest_fg,
    bold = true,
    default = true,
  })
  vim.api.nvim_set_hl(0, "AdhdBreakText", {
    fg = colors.rest_fg,
    bold = true,
    default = true,
  })
end

---Beregner vindusposisjon for øvre høyre hjørne
---@return table
local function get_win_config()
  local hud = config.options.hud
  local col = vim.o.columns + (hud.col_offset or -1)

  return {
    relative = "editor",
    anchor = "NE",
    row = hud.row or 1,
    col = col,
    width = hud.width or 24,
    height = hud.height or 1,
    focusable = false,
    style = "minimal",
    border = hud.border or "rounded",
    zindex = hud.zindex or 100,
  }
end

---Sikrer at bufferen eksisterer og er konfigurert riktig
local function ensure_buffer()
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[M.buf].buftype = "nofile"
    vim.bo[M.buf].bufhidden = "hide"
    vim.bo[M.buf].swapfile = false
  end
  return M.buf
end

---Åpner eller oppdaterer det flytende vinduet
---@param mode "focus"|"break"|"idle"
---@param text string
---@param title string
function M.render(mode, text, title)
  if not config.options.hud.enabled or not M.visible then
    M.close()
    return
  end

  ensure_buffer()

  local win_cfg = get_win_config()
  win_cfg.title = " " .. title .. " "
  win_cfg.title_pos = "center"

  local is_focus = (mode == "focus")
  local hl_ns = is_focus and "FloatBorder:AdhdFocusBorder,FloatTitle:AdhdFocusTitle,Normal:NormalFloat"
    or "FloatBorder:AdhdBreakBorder,FloatTitle:AdhdBreakTitle,Normal:NormalFloat"

  -- Oppdater tekst i bufferen (sentrert eller polstret)
  local width = win_cfg.width
  local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
  local padded_text = string.rep(" ", pad) .. text

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { padded_text })

  -- Påfør tekst-highlight
  local text_hl = is_focus and "AdhdFocusText" or "AdhdBreakText"
  vim.api.nvim_buf_clear_namespace(M.buf, -1, 0, -1)
  local ns = vim.api.nvim_create_namespace("adhd_hud_text")
  vim.api.nvim_buf_add_highlight(M.buf, ns, text_hl, 0, 0, -1)

  if not M.win or not vim.api.nvim_win_is_valid(M.win) then
    M.win = vim.api.nvim_open_win(M.buf, false, win_cfg)
    vim.wo[M.win].winhighlight = hl_ns
    vim.wo[M.win].wrap = false
  else
    vim.api.nvim_win_set_config(M.win, win_cfg)
    vim.wo[M.win].winhighlight = hl_ns
  end
end

---Lukker det flytende vinduet
function M.close()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    pcall(vim.api.nvim_win_close, M.win, true)
  end
  M.win = nil
end

---Toggler synligheten til HUD
function M.toggle_visibility()
  M.visible = not M.visible
  if not M.visible then
    M.close()
  end
  return M.visible
end

---Justerer vinduet når terminalen endrer størrelse
function M.handle_resize()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    local cfg = get_win_config()
    vim.api.nvim_win_set_config(M.win, {
      row = cfg.row,
      col = cfg.col,
    })
  end
end

return M
