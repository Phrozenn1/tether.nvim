local config = require("tether.config")
local anchor = require("tether.anchor")
local flowmodoro = require("tether.flowmodoro")

local M = {}

---Finner tilstandskatalogen for Tether (samme som tether-desktop)
---@return string
local function get_state_dir()
  local state_home = os.getenv("XDG_STATE_HOME")
  local base_dir
  if state_home and state_home ~= "" then
    base_dir = state_home
  elseif vim.fn.has("win32") == 1 then
    base_dir = os.getenv("LOCALAPPDATA") or vim.fn.expand("~/AppData/Local")
  elseif vim.fn.has("mac") == 1 then
    base_dir = vim.fn.expand("~/Library/Application Support")
  else
    base_dir = vim.fn.expand("~/.local/state")
  end
  local dir = base_dir .. "/tether"
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  return dir
end

---Skriver shutdown-forespørsel til shutdown_request.json for Desktop-appen
---@return boolean
local function write_shutdown_request()
  local path = get_state_dir() .. "/shutdown_request.json"
  local payload = vim.json.encode({ timestamp = os.time() })
  local ok = pcall(vim.fn.writefile, { payload }, path)
  return ok
end

---Legger til kvelds-RAM-dump i ramdumps.md dersom Desktop-appen ikke er installert
---@param now_text string
---@param next_step string
---@return boolean
local function append_evening_ramdump(now_text, next_step)
  local path = get_state_dir() .. "/ramdumps.md"
  local stamp = os.date("%Y-%m-%d %H:%M:%S")
  local lines = {
    string.format("--- PAUSE / SAVE-STATE (%s) ---", stamp),
    string.format("[NÅ]:         %s", now_text ~= "" and now_text or "(ikke oppgitt)"),
    "[STATUS]:     Dagsavslutning (parkert for kvelden)",
    string.format("[NESTE STEG]: %s", next_step ~= "" and next_step or "(ikke oppgitt)"),
    "--------------------------------------------",
    "",
  }

  local existing = {}
  if vim.fn.filereadable(path) == 1 then
    existing = vim.fn.readfile(path)
  end
  vim.list_extend(existing, lines)
  local ok = pcall(vim.fn.writefile, existing, path)
  return ok
end

---Neovim-fallback når Tether Desktop ikke er tilgjengelig
local function prompt_neovim_shutdown_fallback()
  vim.ui.input({ prompt = "🌙 Hvor er du nå? (kort status for i morgen): " }, function(now_input)
    if now_input == nil then
      vim.notify(
        "🌙 Anker lagret og timer nullstilt. Kvelds-RAM-dump ble avbrutt.",
        vim.log.levels.INFO,
        { title = "Tether Shutdown" }
      )
      return
    end

    vim.ui.input({ prompt = "📌 Første lille steg i morgen tidlig: " }, function(next_input)
      if next_input == nil then
        next_input = ""
      end

      local now_trimmed = vim.trim(now_input)
      local next_trimmed = vim.trim(next_input)
      if now_trimmed ~= "" or next_trimmed ~= "" then
        if append_evening_ramdump(now_trimmed, next_trimmed) then
          vim.notify(
            "🌙 Arbeidsminnet er trygt parkert i ramdumps.md. God kveld!",
            vim.log.levels.INFO,
            { title = "Tether Shutdown" }
          )
        else
          vim.notify(
            "Klarte ikke lagre RAM-dump til ramdumps.md",
            vim.log.levels.ERROR,
            { title = "Tether Shutdown" }
          )
        end
      else
        vim.notify(
          "🌙 Anker lagret og timer nullstilt. God kveld!",
          vim.log.levels.INFO,
          { title = "Tether Shutdown" }
        )
      end
    end)
  end)
end

---Kjører dagsavslutnings-rutinen: lagrer anker, nullstiller timer og åpner Tether Shutdown
function M.run()
  anchor.save("Dagsavslutning")
  flowmodoro.reset()

  local wrote_req = write_shutdown_request()
  local companion = config.options.companion or {}
  local desktop_cmd = companion.desktop_cmd or "tether"

  if desktop_cmd ~= "" and vim.fn.executable(desktop_cmd) == 1 then
    vim.fn.jobstart({ desktop_cmd, "--shutdown" }, { detach = true })
    if wrote_req then
      vim.notify(
        "🌙 Dagsavslutning startet i Tether Desktop — anker lagret og timer nullstilt.",
        vim.log.levels.INFO,
        { title = "Tether Shutdown" }
      )
    else
      vim.notify(
        "🌙 Tether Desktop startet med --shutdown (kunne ikke skrive shutdown_request.json).",
        vim.log.levels.WARN,
        { title = "Tether Shutdown" }
      )
    end
  else
    prompt_neovim_shutdown_fallback()
  end
end

return M
