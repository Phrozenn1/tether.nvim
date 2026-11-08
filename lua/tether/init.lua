local config = require("tether.config")
local ramdump = require("tether.ramdump")
local flowmodoro = require("tether.flowmodoro")
local impulse = require("tether.impulse")
local yak = require("tether.yak")
local ui = require("tether.ui")

local M = {}

M.ramdump = ramdump
M.flowmodoro = flowmodoro
M.impulse = impulse
M.yak = yak
M.ui = ui
M.config = config

---Registrerer brukerkommandoer
local function setup_user_commands()
  vim.api.nvim_create_user_command("TetherFlowToggle", function()
    flowmodoro.toggle()
  end, { desc = "Tether: Veksle Flowmodoro (Fokus / Pause / Stopp)" })

  vim.api.nvim_create_user_command("TetherFlowReset", function()
    flowmodoro.reset()
  end, { desc = "Tether: Nullstill Flowmodoro og lukk vindu" })

  vim.api.nvim_create_user_command("TetherHud", function()
    flowmodoro.toggle_hud()
  end, { desc = "Tether: Vis eller skjul HUD-vinduet" })

  vim.api.nvim_create_user_command("TetherRamDump", function()
    ramdump.insert()
  end, { desc = "Tether: Sett inn RAM-dump save-state i aktiv buffer" })

  vim.api.nvim_create_user_command("TetherResume", function()
    ramdump.resume()
  end, { desc = "Tether: Gjenoppta fra siste RAM-dump posisjon" })

  vim.api.nvim_create_user_command("TetherImpulse", function()
    impulse.capture()
  end, { desc = "Tether: Fange strøtanke / side-quest" })

  vim.api.nvim_create_user_command("TetherImpulseList", function()
    impulse.open_list()
  end, { desc = "Tether: Åpne listen over lagrede impulser" })
end

---Registrerer tastatursnarveier under <leader>t
local function setup_keymaps()
  local km = config.options.keymaps
  if not km then
    return
  end

  if km.flow_toggle then
    vim.keymap.set("n", km.flow_toggle, function()
      flowmodoro.toggle()
    end, { desc = "Tether: Flowmodoro Toggle (Fokus/Pause)" })
  end

  if km.flow_reset then
    vim.keymap.set("n", km.flow_reset, function()
      flowmodoro.reset()
    end, { desc = "Tether: Flowmodoro Reset" })
  end

  if km.hud_toggle then
    vim.keymap.set("n", km.hud_toggle, function()
      flowmodoro.toggle_hud()
    end, { desc = "Tether: Toggle HUD" })
  end

  if km.ramdump then
    vim.keymap.set("n", km.ramdump, function()
      ramdump.insert()
    end, { desc = "Tether: RAM-dump save-state" })
  end

  if km.resume then
    vim.keymap.set("n", km.resume, function()
      ramdump.resume()
    end, { desc = "Tether: Gjenoppta fra forrige dump" })
  end

  if km.impulse then
    vim.keymap.set("n", km.impulse, function()
      impulse.capture()
    end, { desc = "Tether: Fange side-quest / impuls" })
  end
end

---Registrerer autocommands for vinduer, fargetema og yak-shaving
local function setup_autocmds()
  local grp = vim.api.nvim_create_augroup("TetherPlugin", { clear = true })

  -- Juster HUD-posisjon ved terminalendring
  vim.api.nvim_create_autocmd("VimResized", {
    group = grp,
    callback = function()
      ui.handle_resize()
    end,
  })

  -- Gjenopprett highlight-grupper ved tema-bytte
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = grp,
    callback = function()
      ui.setup_highlights()
    end,
  })

  -- Yak-shaving detektor ved bufferbytte
  vim.api.nvim_create_autocmd("BufEnter", {
    group = grp,
    callback = function(args)
      yak.check_buffer(args.buf)
    end,
  })
end

---Hovedoppsett for tether.nvim
---@param user_opts? TetherConfig
function M.setup(user_opts)
  config.setup(user_opts)
  ui.setup_highlights()
  setup_user_commands()
  setup_keymaps()
  setup_autocmds()
end

return M
