# ADHD-structure.nvim

Et verktøy for Neovim designet for å motvirke **eksekutiv dysfunksjon**, **tidsblindhet** og **kognitiv treghet** under krevende arbeid og studier.

---

## Bakgrunn & Filosofi

Klassiske Pomodoro-timere (f.eks. 25/5 min) skjærer brutalt gjennom dype tankerekker og hyperfokus, mens fri jobbing ofte fører til utmattelse og manglende pauser. 

**ADHD-structure** løser dette med to kjernekonsepter:
1. **Flowmodoro-timer:** En stoppeklokke som teller *oppover* så lenge du har god flyt. Når du velger å stoppe, beregnes pausen automatisk basert på et **45:15-forhold** (f.eks. 60 min fokus gir 20 min pause).
2. **Floating HUD:** Et passivt *always-on-top* vindu øverst i høyre hjørne. Rammen lyser **grønt under fokus** og **rødt under pause**. Vinduet er ikke-fokuserbart (`focusable = false`), slik at markøren aldri hopper inn eller forstyrrer skrivingen.
3. **RAM-dump save-state:** En 60-sekunders protokoll for å fryse tilstanden i arbeidsminnet før du forlater pulten, slik at du slipper frykten for å miste den mentale tråden.

---

## Funksjonalitet

### 1. Flowmodoro HUD (Always-on-top)
- **Fokus-modus (grønn ramme):** Teller oppover (`󰔛 24:15`).
- **Pause-modus (rød ramme):** Teller nedover fra opptjent tid (`󱫡 07:45`).
- **45:15 Ratio:** Pausetid = $\text{Fokustid} \times \frac{15}{45}$ (tilsvarer $\frac{1}{3}$ av arbeidstiden).
- **Varsling:** Sender `vim.notify`-varsel når pausen er over og minner deg på å ta en RAM-dump idet fokus avsluttes.

### 2. RAM-dump
Setter inn følgende mal rett under markøren (eller på gjeldende tomme linje) og starter umiddelbart i Insert Mode:

```markdown
--- PAUSE / SAVE-STATE ---
[NÅ]:        
[STATUS]:    
[NESTE STEG]: 
---------------------------
```

---

## Installasjon

### Med `lazy.nvim` (lokal mappe)

Legg til f.eks. i `~/.config/nvim/lua/plugins/adhd-structure.lua`:

```lua
return {
  dir = "~/Projects/ADHD-structure",
  name = "adhd-structure",
  event = "VeryLazy",
  opts = {
    ratio = {
      focus = 45,
      rest = 15,
    },
    keymaps = {
      ramdump = "<leader>rd",
      flowmodoro_toggle = "<leader>rf",
      flowmodoro_reset = "<leader>rF",
      hud_toggle = "<leader>rh",
    },
  },
}
```

---

## Standard Tastatursnarveier

| Snarvei | Funksjon | Beskrivelse |
| :--- | :--- | :--- |
| `<leader>rf` | **Veksle Flowmodoro** | Starter fokus $\rightarrow$ Bytter til pause $\rightarrow$ Stopper |
| `<leader>rF` | **Nullstill Flowmodoro** | Stopper timeren og lukker HUD-vinduet |
| `<leader>rh` | **Toggle HUD** | Skjuler eller viser det flytende vinduet |
| `<leader>rd` | **RAM-dump** | Setter inn save-state mal og går i Insert Mode |

---

## Brukerkommandoer

- `:AdhdFlowmodoroToggle` – Start / bytt til pause / avslutt.
- `:AdhdFlowmodoroReset` – Nullstill timer og lukk vindu.
- `:AdhdFlowmodoroHud` – Skjul/vis HUD-vinduet.
- `:AdhdRamDump` – Sett inn RAM-dump.

---

## Konfigurasjon (Standardverdier)

```lua
require("adhd-structure").setup({
  -- Forhold mellom fokus og pause (standard 45:15)
  ratio = {
    focus = 45,
    rest = 15,
  },
  hud = {
    enabled = true,
    row = 1,
    col_offset = -1,  -- Avstand fra høyre kant
    width = 24,
    height = 1,
    border = "rounded",
    zindex = 100,
    colors = {
      focus_border = "#98c379", -- Grønn ramme under fokus
      focus_fg = "#98c379",
      rest_border = "#e06c75",  -- Rød ramme under pause
      rest_fg = "#e06c75",
      title_fg = "#abb2bf",
    },
  },
  ramdump = {
    cursor_line_offset = 2,
    cursor_col = 13,
  },
  notifications = {
    enabled = true,
    remind_ramdump = true,
  },
  keymaps = {
    ramdump = "<leader>rd",
    flowmodoro_toggle = "<leader>rf",
    flowmodoro_reset = "<leader>rF",
    hud_toggle = "<leader>rh",
  },
})
```
