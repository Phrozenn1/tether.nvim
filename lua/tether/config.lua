local M = {}

---@class TetherConfig
M.defaults = {
  -- Flowmodoro ratio: Forhold mellom fokus og pause (standard 45:15)
  ratio = {
    focus = 45,
    rest = 15,
  },
  -- Floating HUD innstillinger (always-on-top i øvre høyre hjørne)
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
  -- RAM-dump (kognitiv save-state)
  ramdump = {
    template = {
      "--- PAUSE / SAVE-STATE ---",
      "[NÅ]:        ",
      "[STATUS]:    ",
      "[NESTE STEG]: ",
      "---------------------------",
    },
    cursor_line_offset = 2,
    cursor_col = 13,
  },
  -- Side-quest / Impulsbuffer
  impulse = {
    file = vim.fn.stdpath("data") .. "/tether_impulses.md",
  },
  -- Yak-Shaving / Kaninhull-detektor
  yak_shaving = {
    enabled = true,
    throttle_seconds = 300, -- Maks ett stikk per 5 minutter
    config_patterns = {
      "/%.config/nvim/",
      "/dotfiles/",
      "/%.dotfiles/",
      "/%.bashrc",
      "/%.zshrc",
      "/%.tmux%.conf",
      "/hypr/.*%.conf",
    },
    jabs = {
      "Å tweake Neovim-konfigurasjonen teller dessverre ikke som pensumlesing.",
      "Jada, koden kjører sikkert mye raskere bare markøren er to piksler tykkere.",
      "Gratulerer! Du har nå brukt 40 minutter på å automatisere en 3-sekunders oppgave.",
      "Å bytte fra 'rounded' til 'single' borders kommer ikke til å redde innleveringsfristen din.",
      "Dopaminet fra det nye fargetemaet varer i nøyaktig 3 minutter. Lukk dotfiles og gå tilbake til koden.",
      "Å nei... du åpnet config-mappa igjen. Skal vi hente redningshelikopter?",
      "Den jaken du barberer nå har vært naken i over en halvtime.",
      "Du skulle fikse én feilmelding. Hvorfor skriver du din egen JSON-parser i Lua nå?",
      "Du er fire lag dypere inn i et kaninhull enn da du startet. Pust med magen og lukk bufferen.",
      "Skal vi late som om denne regex-optimaliseringen var helt kritisk, eller skal du skrive ferdig funksjonen?",
      "Husker du i det hele tatt hva filen du åpnet for en time siden het?",
      "Dette er ikke produktivitet. Dette er prokrastinering i smoking.",
      "Hjernen din: 'Dette er superviktig og haster!' Realiteten: 'Du vasker tastaturet med q-tips'.",
      "Er denne mikroskopiske omstruktureringen godkjent av samvittigheten din?",
      "Hvis denne sidespors-ideen er så fantastisk, trykk <leader>ti for å dumpe den – og kom deg tilbake på sporet!",
      "Flott arkitektur på den hjelpefunksjonen! Synd ingen ba om den.",
    },
  },
  -- Standard tastatursnarveier (<leader>t)
  keymaps = {
    flow_toggle = "<leader>tf",
    flow_reset = "<leader>tF",
    hud_toggle = "<leader>th",
    ramdump = "<leader>td",
    impulse = "<leader>ti",
    resume = "<leader>tr",
  },
  -- Notifikasjoner
  notifications = {
    enabled = true,
    remind_ramdump = true,
  },
}

---@type TetherConfig
M.options = vim.deepcopy(M.defaults)

---@param user_opts? TetherConfig
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts or {})
end

return M
