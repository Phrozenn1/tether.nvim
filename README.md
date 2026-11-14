# tether.nvim ⚓

[![GitHub release](https://img.shields.io/github/v/release/Phrozenn1/tether.nvim?style=flat-square&color=22d3ee)](https://github.com/Phrozenn1/tether.nvim/releases)
[![Neovim >= 0.9.0](https://img.shields.io/badge/Neovim-%3E%3D0.9.0-57A143?style=flat-square&logo=neovim)](https://neovim.io)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg?style=flat-square)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-Phrozenn1%2Ftether--nvim-181717?style=flat-square&logo=github)](https://github.com/Phrozenn1/tether.nvim)

> **Flowmodoro timer, RAM-dump save-states, and cognitive anchoring for deep work, neurodivergent minds, and focus.**  
> Seamlessly integrated with [Tether Desktop](https://github.com/Phrozenn1/tether-desktop), [tether-vscode](https://github.com/Phrozenn1/tether-vscode), and [tether-obsidian](https://github.com/Phrozenn1/tether-obsidian).

A humane deep-work companion for Neovim. Engineered with universal design principles that empower neurodivergent minds (**ADHD**, **Autism/ASD**, **Dyslexia**, and **AuDHD**) while providing an unbeatably calm, distraction-free environment for **any writer, researcher, or developer** seeking sustainable focus.

---

## ⏱️ Why Flowmodoro Instead of Pomodoro?

Traditional Pomodoro (25m work / 5m break) frequently backfires for deep creative and analytical work: it forcibly interrupts hyperfocus and monotropic attention tunnels mid-thought, destroying fragile working memory contexts that took 40 minutes to assemble.

**Flowmodoro** solves this by counting **UP**:

| Traditional Pomodoro | Flowmodoro in `tether.nvim` |
| :--- | :--- |
| **Fixed timer (counts DOWN from 25m)** | **Open stopwatch (counts UP)** — ride your flow as long as it lasts |
| **Cuts you off mid-thought** | You choose when to stop when mental friction naturally rises |
| **Fixed 5m break** | **Proportional break (45:15 ratio)** — e.g. 60m focus earns a 20m break |
| **High re-entry friction** | **60s RAM-dump** captures your state so you can resume seamlessly |

---

## ✨ Features

- **Heads-Up Display (Floating HUD):**
  - Stays pinned to the top-right corner (`anchor = "NE"`) above all splits.
  - Completely unfocusable (`focusable = false`) — your cursor will never accidentally land inside it.
  - Dynamic borders: 🟢 **Green** (`#98c379`) during Focus, 🔴 **Red** (`#e06c75`) during Break, and 🟡 **Warm Amber** (`#e5c07b`) during Micro-Start.
- **5-Minute Micro-Start (`<leader>t5`):**
  - Melts task-initiation paralysis by lowering the psychological bar to just 5 minutes.
  - Automatically transitions into standard Flowmodoro counting up once the 5 minutes are completed.
- **Banked Break Time & Seamless Resumption:**
  - Returning early from a break saves your unspent rest time to your bank and resumes your focus session seamlessly.
- **Context Resumption Anchor (`<leader>tr` / `<leader>ta`):**
  - Jumps your cursor and buffer directly back to where you made your last RAM-dump or saved an anchor.
- **Platform-Agnostic Editor Focus Sync:**
  - Automatically reports focus state (`FocusGained`/`FocusLost`) to `~/.local/state/tether/editor_focus.json` so Tether Desktop can react on any desktop environment (GNOME, KDE, Wayland, X11, macOS, Windows).
- **Proportional Break Ratio (45:15):**
  - Automatically calculates $\frac{15}{45} = \frac{1}{3}$ of your focus time for rest. Fully customizable.
- **60-Second RAM-Dump Save-State (`<leader>td`):**
  - Rapidly injects a minimal 3-line state tracker (`[NÅ]`, `[STATUS]`, `[NESTE STEG]`) and activates Insert Mode.
- **Side-Quest / Impulse Buffer (`<leader>ti`):**
  - Stray thoughts (*"Pay electricity bill"*, *"Refactor database"*) strike constantly. Press `<leader>ti`, type the thought, and hit Enter. It appends to a dated capture file with interactive markdown checkboxes (`- [ ]`) without moving your cursor.
- **Momentum & Flyt-XP (`<leader>tm`):**
  - Shame-free weekly progress tracking without punishing broken streaks.
- **Evening Shutdown Ritual (`<leader>ts` / `:TetherShutdown`):**
  - Cleanly stops active flow, captures an end-of-day summary plus tomorrow's first micro-step to `~/.local/state/tether/ramdumps.md`, and writes `last_shutdown.json` for *"Where Was I?"* morning recovery.
- **Yak-Shaving / Rabbit-Hole Alarm 🪒:**
  - If you drift into tweaking dotfiles (`~/.config/nvim/`, etc.) during an active focus block, Tether delivers a witty/sarcastic reminder to keep you on track.
- **Zero Editor Lag:**
  - 100% native asynchronous Lua built on Neovim's `vim.uv` (libuv) event loop.

---

## ⚡ Requirements

- **Neovim >= 0.9.0** (requires floating window `title` and `vim.uv`/`vim.loop`).
- **Nerd Font** (recommended for icons: `󰔛`, `󱫡`, `󰄬`, `⚓`).

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Phrozenn1/tether.nvim",
  event = "VeryLazy",
  opts = {
    -- Optional custom settings (see Configuration below)
  },
}
```

### [mini.deps](https://github.com/echasnovski/mini.deps)

```lua
MiniDeps.add({ source = "Phrozenn1/tether.nvim" })
require("tether").setup()
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Phrozenn1/tether.nvim'

" In your lua configuration:
lua require('tether').setup()
```

### Manual Installation (Native Neovim Packpath)

```bash
git clone https://github.com/Phrozenn1/tether.nvim.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/plugins/start/tether.nvim"
```

---

## ⌨️ Default Keymaps (`<leader>t`)

| Keymap | Command | Description |
| :--- | :--- | :--- |
| **`<leader>tf`** | `:TetherFlowToggle` | **T**ether **F**low: Cycle Idle $\rightarrow$ Focus $\rightarrow$ Break $\rightarrow$ Idle |
| **`<leader>tF`** | `:TetherFlowReset` | **T**ether **F**orce-stop: Reset timer and close HUD |
| **`<leader>t5`** | `:TetherMicroStart` | **T**ether **5**m: Start low-friction 5-minute Micro-Start |
| **`<leader>th`** | `:TetherHud` | **T**ether **H**UD: Toggle visibility of the floating timer |
| **`<leader>td`** | `:TetherRamDump` | **T**ether **D**ump: Insert 60-second RAM-dump save-state |
| **`<leader>tr`** | `:TetherResume` | **T**ether **R**esume: Jump back to last RAM-dump location |
| **`<leader>ta`** | `:TetherAnchor` | **T**ether **A**nchor: Pin current buffer & line as context anchor |
| **`<leader>tm`** | `:TetherMomentum` | **T**ether **M**omentum: View weekly Flyt-XP stats |
| **`<leader>ti`** | `:TetherImpulse` | **T**ether **I**mpulse: Offload a side-quest / stray thought |
| **`<leader>ts`** | `:TetherShutdown` | **T**ether **S**hutdown: Evening shutdown ritual & park working memory |
| — | `:TetherImpulseList` | Open and toggle tracked impulses in a split/buffer |
| — | `:TetherDesktop` | Launch or focus the native cross-platform Tether Desktop companion |
| — | `:TetherConfig` | Open `~/.config/tether/config.json` in split |

> [!TIP]
> Keymaps can be disabled or modified by setting `keymaps = false` or passing your own mapping dictionary in `opts.keymaps`.

---

## ⚙️ Configuration (Defaults)

```lua
require("tether").setup({
  -- Ratio between focus and break (default 45:15 -> 3:1)
  ratio = {
    focus = 45,
    rest = 15,
  },
  -- Floating HUD window settings
  hud = {
    enabled = true,
    row = 1,
    col_offset = -1, -- Offset from top-right edge
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
      focus_border = "#98c379", -- Green border in focus
      focus_fg = "#98c379",
      micro_border = "#e5c07b", -- Warm amber border in Micro-Start
      micro_fg = "#e5c07b",
      rest_border = "#e06c75",  -- Red border in break
      rest_fg = "#e06c75",
      title_fg = "#abb2bf",
    },
  },
  -- RAM-dump save-state settings
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
  -- Side-quest impulse capture file
  impulse = {
    file = vim.fn.expand("~/.local/state/tether/impulses.md"),
    format = "markdown_checkbox", -- "markdown_checkbox" | "markdown_bullet" | "todo_txt" | "json"
  },
  -- Cross-platform Desktop Companion integration
  companion = {
    auto_start_desktop = true,
    desktop_cmd = "tether",
  },
  -- Sarcastic Yak-Shaving detector
  yak_shaving = {
    enabled = true,
    throttle_seconds = 300, -- Maximum 1 warning per 5 minutes
  },
  -- Default keybindings
  keymaps = {
    flow_toggle = "<leader>tf",
    flow_reset = "<leader>tF",
    micro_start = "<leader>t5",
    hud_toggle = "<leader>th",
    ramdump = "<leader>td",
    impulse = "<leader>ti",
    resume = "<leader>tr",
    anchor = "<leader>ta",
    momentum = "<leader>tm",
    shutdown = "<leader>ts",
  },
})
```

---

## 🔄 Cross-App Ecosystem

Tether is a unified neurodivergent companion across your tools—all sharing state via `~/.local/state/tether/`:
- **[Tether Desktop](https://github.com/Phrozenn1/tether-desktop)**: Cross-platform companion with offline focus soundscapes, AI-assisted RAM-dumps, Dopamine Menu, Time Anchor, and universal app tracking.
- **[tether.nvim](https://github.com/Phrozenn1/tether.nvim)**: This plugin!
- **[tether-vscode](https://github.com/Phrozenn1/tether-vscode)**: Status bar timer, context anchor, and RAM-dump commands for VS Code.
- **[tether-obsidian](https://github.com/Phrozenn1/tether-obsidian)**: Flowmodoro status bar, note anchoring, RAM-dump CRUD manager, and Shutdown Ritual for Obsidian.

---

## 🔬 Scientific Foundation

Tether's Flowmodoro timing, Micro-Start initiation scaffolding, RAM-dump working memory capture, and interruption buffering are grounded in peer-reviewed research in cognitive neuroscience:
- 👉 [**`RESEARCH.md` — Scientific Rationale & Neurodivergent Research Foundation**](https://github.com/Phrozenn1/tether-desktop/blob/main/RESEARCH.md)

---

## 🏷️ Topics / Keywords

`flowmodoro` `flowmodoro-timer` `neovim-plugin` `pomodoro` `neurodiversity` `adhd` `autism` `dyslexia` `deep-work` `executive-function` `productivity` `lua`

---

## 📄 License

[GPL-2.0](LICENSE) © [Phrozenn1](https://github.com/Phrozenn1)
