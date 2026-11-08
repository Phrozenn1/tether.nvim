# adhd-structure.nvim

A lightweight Neovim workflow plugin designed to mitigate **executive dysfunction**, **time blindness**, and **cognitive inertia** during intensive programming and study sessions.

---

## 💡 The Philosophy

Standard Pomodoro techniques (like 25m focus / 5m break) frequently backfire with ADHD: they forcibly break hyperfocus mid-thought, destroying fragile mental context that took 40 minutes to build.

**adhd-structure.nvim** provides an alternative cognitive architecture:

1. **Flowmodoro Engine (Count Up):** A stopwatch that counts *upwards* as long as you have natural focus. When your mental stamina wanes, stop the session—the plugin automatically calculates your earned break based on a **45:15 ratio** ($\frac{1}{3}$ of your focus time).
2. **Always-on-Top Floating HUD:** A minimalist, unfocusable (`focusable = false`) window in the upper-right corner. It stays pinned above all splits without stealing focus. The border glows **green during focus** and turns **red during break**.
3. **60-Second RAM-Dump Protocol:** A rapid 3-line save-state to freeze working memory before stepping away, removing the anxiety of losing your mental model.

---

## ✨ Features

- **Top-Right Floating HUD:** Pinned to `anchor = "NE"`, responsive to editor resizing (`VimResized`).
- **Dynamic Colored Borders:**
  - 🟢 **Green** (`#98c379`) during Focus sessions.
  - 🔴 **Red** (`#e06c75`) during Break countdown.
- **Proportional Break Calculation (45:15):** Work 45m $\rightarrow$ get 15m break. Work 60m $\rightarrow$ get 20m break. Fully customizable.
- **Cognitive Save-State (RAM-Dump):** Instant insertion of state-tracking template with cursor automatically placed in Insert Mode.
- **Zero Overhead:** Uses Neovim's asynchronous `vim.uv` (libuv) event loop—never blocks or lags the editor.

---

## ⚡ Requirements

- **Neovim >= 0.9.0** (requires floating window `title` and `vim.uv`/`vim.loop`).
- **Nerd Font** (recommended for icons like `󰔛`, `󱫡`, `󰄬`).

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Phrozenn1/adhd-structure.nvim",
  event = "VeryLazy",
  opts = {
    -- Optional custom configuration here (see Configuration section)
  },
}
```

### [mini.deps](https://github.com/echasnovski/mini.deps)

```lua
MiniDeps.add({
  source = "Phrozenn1/adhd-structure.nvim",
})
require("adhd-structure").setup()
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Phrozenn1/adhd-structure.nvim'

" In your init.lua / lua block:
lua require('adhd-structure').setup()
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "Phrozenn1/adhd-structure.nvim",
  config = function()
    require("adhd-structure").setup()
  end,
})
```

### Manual Installation (Native Neovim Packpath)

No package manager required:

```bash
git clone https://github.com/Phrozenn1/adhd-structure.nvim.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/plugins/start/adhd-structure.nvim"
```

Then add to your `init.lua`:

```lua
require("adhd-structure").setup()
```

---

## ⌨️ Default Keymaps

| Keymap | Command | Description |
| :--- | :--- | :--- |
| `<leader>rf` | `:AdhdFlowmodoroToggle` | Toggle Flowmodoro (Idle $\rightarrow$ Focus $\rightarrow$ Break $\rightarrow$ Idle) |
| `<leader>rF` | `:AdhdFlowmodoroReset` | Reset timer and close HUD window |
| `<leader>rh` | `:AdhdFlowmodoroHud` | Toggle HUD visibility (timer runs in background) |
| `<leader>rd` | `:AdhdRamDump` | Insert 3-line RAM-dump template & start Insert Mode |

> [!NOTE]
> All keymaps can be customized or disabled by setting `keymaps = false` in your configuration.

---

## 📝 The RAM-Dump Template

When pressing `<leader>rd` (or `:AdhdRamDump`), the following template is inserted:

```markdown
--- PAUSE / SAVE-STATE ---
[NÅ]:        
[STATUS]:    
[NESTE STEG]: 
---------------------------
```

The cursor is placed immediately after `[NÅ]: ` in **Insert Mode** so you can dump your working memory in under 60 seconds.

---

## ⚙️ Configuration

Default options:

```lua
require("adhd-structure").setup({
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
      focus_border = "#98c379", -- Green border for focus
      focus_fg = "#98c379",
      rest_border = "#e06c75",  -- Red border for break
      rest_fg = "#e06c75",
      title_fg = "#abb2bf",
    },
  },
  -- RAM-dump configuration
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
  -- Notifications
  notifications = {
    enabled = true,
    remind_ramdump = true, -- Reminder to take a RAM-dump when ending focus
  },
  -- Default keybindings
  keymaps = {
    ramdump = "<leader>rd",
    flowmodoro_toggle = "<leader>rf",
    flowmodoro_reset = "<leader>rF",
    hud_toggle = "<leader>rh",
  },
})
```

---

## 📄 License

MIT © [Kim Bech](https://github.com/Phrozenn1)
