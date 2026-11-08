local M = {}

---@class AdhdStructureRatio
---@field focus number Antall minutter fokus
---@field rest number Antall minutter pause

---@class AdhdStructureConfig
M.defaults = {
  -- Forhold mellom fokus og pause (standard 45:15)
  ratio = {
    focus = 45,
    rest = 15,
  },
  -- Floating HUD innstillinger
  hud = {
    enabled = true,
    row = 1,
    col_offset = -1, -- Avstand fra høyre kant
    width = 24,
    height = 1,
    border = "rounded",
    zindex = 100,
    icons = {
      focus = "󰔛",
      rest = "󱫡",
      done = "󰄬",
    },
    colors = {
      focus_border = "#98c379", -- Grønn ramme for fokus
      focus_fg = "#98c379",
      rest_border = "#e06c75",  -- Rød ramme for pause
      rest_fg = "#e06c75",
      title_fg = "#abb2bf",
    },
  },
  -- RAM-dump innstillinger
  ramdump = {
    template = {
      "--- PAUSE / SAVE-STATE ---",
      "[NÅ]:        ",
      "[STATUS]:    ",
      "[NESTE STEG]: ",
      "---------------------------",
    },
    cursor_line_offset = 2, -- Hvilken linje markøren skal havne på (1-indeksert fra start av mal)
    cursor_col = 13,        -- Kolonne rett etter '[NÅ]: '
  },
  -- Standard tastatursnarveier (sett til false for å deaktivere)
  keymaps = {
    ramdump = "<leader>rd",
    flowmodoro_toggle = "<leader>rf",
    flowmodoro_reset = "<leader>rF",
    hud_toggle = "<leader>rh",
  },
  -- Notifikasjoner
  notifications = {
    enabled = true,
    remind_ramdump = true, -- Minn på RAM-dump når fokus avsluttes
  },
}

---@type AdhdStructureConfig
M.options = vim.deepcopy(M.defaults)

---@param user_opts? AdhdStructureConfig
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts or {})
end

return M
