local config = require("adhd-structure.config")
local ramdump = require("adhd-structure.ramdump")
local flowmodoro = require("adhd-structure.flowmodoro")
local ui = require("adhd-structure.ui")

local M = {}

M.ramdump = ramdump
M.flowmodoro = flowmodoro
M.ui = ui
M.config = config

---Registrerer brukerkommandoer
local function setup_user_commands()
  vim.api.nvim_create_user_command("AdhdRamDump", function()
    ramdump.insert()
  end, { desc = "Sett inn RAM-dump mal i gjeldende buffer" })

  vim.api.nvim_create_user_command("AdhdFlowmodoroToggle", function()
    flowmodoro.toggle()
  end, { desc = "Veksle Flowmodoro (Fokus / Pause / Stopp)" })

  vim.api.nvim_create_user_command("AdhdFlowmodoroReset", function()
    flowmodoro.reset()
  end, { desc = "Nullstill Flowmodoro og lukk vindu" })

  vim.api.nvim_create_user_command("AdhdFlowmodoroHud", function()
    flowmodoro.toggle_hud()
  end, { desc = "Vis eller skjul Flowmodoro HUD-vinduet" })
end

---Registrerer tastatursnarveier hvis konfigurert
local function setup_keymaps()
  local km = config.options.keymaps
  if not km then
    return
  end

  if km.ramdump then
    vim.keymap.set("n", km.ramdump, function()
      ramdump.insert()
    end, { desc = "ADHD: RAM-dump save-state" })
  end

  if km.flowmodoro_toggle then
    vim.keymap.set("n", km.flowmodoro_toggle, function()
      flowmodoro.toggle()
    end, { desc = "ADHD: Flowmodoro Toggle (Fokus/Pause)" })
  end

  if km.flowmodoro_reset then
    vim.keymap.set("n", km.flowmodoro_reset, function()
      flowmodoro.reset()
    end, { desc = "ADHD: Flowmodoro Reset" })
  end

  if km.hud_toggle then
    vim.keymap.set("n", km.hud_toggle, function()
      flowmodoro.toggle_hud()
    end, { desc = "ADHD: Flowmodoro Toggle HUD" })
  end
end

---Registrerer autocommands for vindusjustering og fargetema
local function setup_autocmds()
  local grp = vim.api.nvim_create_augroup("AdhdStructure", { clear = true })

  -- Juster HUD-posisjon når vinduet/terminalen endrer størrelse
  vim.api.nvim_create_autocmd("VimResized", {
    group = grp,
    callback = function()
      ui.handle_resize()
    end,
  })

  -- Gjenopprett highlight-grupper når fargetema byttes
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = grp,
    callback = function()
      ui.setup_highlights()
    end,
  })
end

---Hovedoppsett for ADHD-structure
---@param user_opts? AdhdStructureConfig
function M.setup(user_opts)
  config.setup(user_opts)
  ui.setup_highlights()
  setup_user_commands()
  setup_keymaps()
  setup_autocmds()
end

return M
