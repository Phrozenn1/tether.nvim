if vim.g.loaded_tether == 1 then
  return
end
vim.g.loaded_tether = 1

if vim.fn.exists(":TetherFlowToggle") == 0 then
  vim.api.nvim_create_user_command("TetherFlowToggle", function()
    require("tether").setup()
    require("tether.flowmodoro").toggle()
  end, { desc = "Tether: Veksle Flowmodoro" })
end

if vim.fn.exists(":TetherRamDump") == 0 then
  vim.api.nvim_create_user_command("TetherRamDump", function()
    require("tether").setup()
    require("tether.ramdump").insert()
  end, { desc = "Tether: Sett inn RAM-dump mal" })
end

if vim.fn.exists(":TetherImpulse") == 0 then
  vim.api.nvim_create_user_command("TetherImpulse", function()
    require("tether").setup()
    require("tether.impulse").capture()
  end, { desc = "Tether: Fange side-quest / impuls" })
end
