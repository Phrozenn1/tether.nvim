-- Standard entrypoint for Neovim runtimepath discovery
if vim.g.loaded_adhd_structure == 1 then
  return
end
vim.g.loaded_adhd_structure = 1

-- Opprett standardkommandoer hvis setup() ikke er kalt manuelt
if vim.fn.exists(":AdhdFlowmodoroToggle") == 0 then
  vim.api.nvim_create_user_command("AdhdFlowmodoroToggle", function()
    require("adhd-structure").setup()
    require("adhd-structure.flowmodoro").toggle()
  end, { desc = "Veksle Flowmodoro (Fokus / Pause / Stopp)" })
end

if vim.fn.exists(":AdhdRamDump") == 0 then
  vim.api.nvim_create_user_command("AdhdRamDump", function()
    require("adhd-structure").setup()
    require("adhd-structure.ramdump").insert()
  end, { desc = "Sett inn RAM-dump mal i gjeldende buffer" })
end
