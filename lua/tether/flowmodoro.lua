local config = require("tether.config")
local ui = require("tether.ui")

local M = {
  STATE_IDLE = "idle",
  STATE_FOCUS = "focus",
  STATE_BREAK = "break",

  state = "idle",
  timer = nil,
  sync_timer = nil,
  elapsed_focus_sec = 0,
  remaining_break_sec = 0,
  break_duration_sec = 0,
  start_epoch = 0,
  seq = 0,
  last_seen_desktop_seq = 0,
}

---Sti til felles tilstandsfil for synkronisering med Tether Desktop
local function get_state_file()
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
  return dir .. "/flow_state.json"
end

---Formaterer sekunder til MM:SS eller HH:MM:SS
---@param seconds number
---@return string
local function format_time(seconds)
  local s = math.max(0, math.floor(seconds))
  local hrs = math.floor(s / 3600)
  local mins = math.floor((s % 3600) / 60)
  local secs = s % 60

  if hrs > 0 then
    return string.format("%02d:%02d:%02d", hrs, mins, secs)
  else
    return string.format("%02d:%02d", mins, secs)
  end
end

---Beregner opptjent pausetid basert på fokus-tid og ratio (f.eks. 45:15)
---@param focus_sec number
---@return number
local function calculate_break_time(focus_sec)
  local ratio = config.options.ratio
  local focus_base = math.max(1, ratio.focus or 45)
  local rest_base = math.max(1, ratio.rest or 15)

  local break_sec = math.floor(focus_sec * (rest_base / focus_base))
  return math.max(30, break_sec)
end

---Kringkaster gjeldende tilstand til Tether Desktop
local function broadcast_state()
  local file = get_state_file()
  M.seq = (M.seq or 0) + 1
  M.last_seen_desktop_seq = M.seq
  local payload = {
    state = M.state,
    start_epoch = M.start_epoch or os.time(),
    break_duration_sec = M.break_duration_sec or 0,
    elapsed_focus_sec = M.elapsed_focus_sec or 0,
    remaining_break_sec = M.remaining_break_sec or 0,
    focus_ratio = config.options.ratio.focus or 45,
    break_ratio = config.options.ratio.rest or 15,
    writer = "nvim",
    seq = M.seq,
    timestamp = os.time(),
  }

  local ok, json = pcall(vim.json.encode, payload)
  if ok then
    local f = io.open(file, "w")
    if f then
      f:write(json)
      f:close()
    end
  end
end

---Sjekker om Tether Desktop har oppdatert tilstanden
function M.check_external_sync()
  local file = get_state_file()
  local f = io.open(file, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then
    return
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return
  end

  local is_new_seq = (data.seq ~= M.last_seen_desktop_seq)
  local is_desktop = (data.writer == "desktop")
  local is_startup_recovery = (M.last_seen_desktop_seq == 0 and data.state ~= "idle" and M.state == "idle")

  if (is_desktop and is_new_seq) or is_startup_recovery then
    M.last_seen_desktop_seq = data.seq
    M.seq = data.seq

    local now = os.time()
    if data.state == "focus" then
      M.state = M.STATE_FOCUS
      M.start_epoch = data.start_epoch or now
      M.elapsed_focus_sec = math.max(0, now - M.start_epoch)
      M.start_uv_timer()

      local time_str = format_time(M.elapsed_focus_sec)
      local icon = config.options.hud.icons.focus or "󰔛"
      ui.render("focus", string.format("%s %s", icon, time_str), "Fokus (Desktop)")

    elseif data.state == "break" then
      M.state = M.STATE_BREAK
      M.start_epoch = data.start_epoch or now
      M.break_duration_sec = data.break_duration_sec or data.remaining_break_sec or 300
      local elapsed = math.max(0, now - M.start_epoch)
      M.remaining_break_sec = math.max(0, M.break_duration_sec - elapsed)
      M.start_uv_timer()

      local time_str = format_time(M.remaining_break_sec)
      local icon = config.options.hud.icons.rest or "󱫡"
      ui.render("break", string.format("%s %s", icon, time_str), "Pause (Desktop)")

    elseif data.state == "idle" then
      M.state = M.STATE_IDLE
      M.elapsed_focus_sec = 0
      M.remaining_break_sec = 0
      M.start_epoch = 0
      M.stop_timer()
      ui.close()
    end
  end
end

---Starter bakgrunnssynkronisering med Tether Desktop
function M.start_sync_watcher()
  if M.sync_timer then
    return
  end

  -- Sjekk synkronisering umiddelbart ved oppstart
  M.check_external_sync()

  local uv = vim.uv or vim.loop
  M.sync_timer = uv.new_timer()
  M.sync_timer:start(
    400,
    400,
    vim.schedule_wrap(function()
      M.check_external_sync()
    end)
  )
end

---Sjekker om en aktiv fokusøkt pågår
---@return boolean
function M.is_focus_active()
  return M.state == M.STATE_FOCUS
end

---Oppdaterer HUD og intern tilstand ved hver timer-tikk
local function tick()
  if M.state == M.STATE_FOCUS then
    if M.start_epoch and M.start_epoch > 0 then
      M.elapsed_focus_sec = math.max(0, os.time() - M.start_epoch)
    else
      M.elapsed_focus_sec = M.elapsed_focus_sec + 1
    end

    local time_str = format_time(M.elapsed_focus_sec)
    local icon = config.options.hud.icons.focus or "󰔛"
    ui.render("focus", string.format("%s %s", icon, time_str), "Fokus")

  elseif M.state == M.STATE_BREAK then
    if M.start_epoch and M.start_epoch > 0 and M.break_duration_sec and M.break_duration_sec > 0 then
      local elapsed = math.max(0, os.time() - M.start_epoch)
      M.remaining_break_sec = math.max(0, M.break_duration_sec - elapsed)
    else
      M.remaining_break_sec = M.remaining_break_sec - 1
    end

    if M.remaining_break_sec <= 0 then
      M.state = M.STATE_IDLE
      M.stop_timer()
      broadcast_state()

      local icon_done = config.options.hud.icons.done or "󰄬"
      ui.render("break", string.format("%s Ferdig!", icon_done), "Pause over")

      if config.options.notifications.enabled then
        vim.notify("Pausen er over! 🚀 Klar for neste fokusøkt?", vim.log.levels.WARN, {
          title = "Tether Flowmodoro",
        })
      end

      vim.defer_fn(function()
        if M.state == M.STATE_IDLE then
          ui.close()
        end
      end, 6000)
    else
      local time_str = format_time(M.remaining_break_sec)
      local icon = config.options.hud.icons.rest or "󱫡"
      ui.render("break", string.format("%s %s", icon, time_str), "Pause")
    end
  end
end

---Starter bakgrunnstimeren (libuv)
function M.start_uv_timer()
  if not M.timer then
    local uv = vim.uv or vim.loop
    M.timer = uv.new_timer()
  end

  M.timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      tick()
    end)
  )
end

---Stopper bakgrunnstimeren
function M.stop_timer()
  if M.timer then
    pcall(function()
      M.timer:stop()
    end)
  end
end

---Starter en fokusøkt (teller oppover)
function M.start_focus()
  M.state = M.STATE_FOCUS
  M.start_epoch = os.time()
  M.elapsed_focus_sec = 0
  M.start_uv_timer()
  broadcast_state()

  local icon = config.options.hud.icons.focus or "󰔛"
  ui.render("focus", string.format("%s 00:00", icon), "Fokus")

  if config.options.notifications.enabled then
    vim.notify("Fokusøkt startet! Jobb i flyt så lenge du orker.", vim.log.levels.INFO, {
      title = "Tether Flowmodoro",
    })
  end
end

---Avslutter fokus og går over til pause basert på ratio (f.eks. 45:15)
function M.start_break()
  if M.elapsed_focus_sec < 10 then
    M.reset()
    if config.options.notifications.enabled then
      vim.notify("Økt avbrutt (under 10 sekunder).", vim.log.levels.INFO, { title = "Tether" })
    end
    return
  end

  local break_sec = calculate_break_time(M.elapsed_focus_sec)
  local focus_formatted = format_time(M.elapsed_focus_sec)
  local break_formatted = format_time(break_sec)

  M.state = M.STATE_BREAK
  M.start_epoch = os.time()
  M.break_duration_sec = break_sec
  M.remaining_break_sec = break_sec
  broadcast_state()

  local icon = config.options.hud.icons.rest or "󱫡"
  ui.render("break", string.format("%s %s", icon, break_formatted), "Pause")

  if config.options.notifications.enabled then
    local msg = string.format("Fokusøkt: %s.\nOpptjent pause (45:15): %s.", focus_formatted, break_formatted)
    if config.options.notifications.remind_ramdump then
      local key = config.options.keymaps.ramdump or "<leader>td"
      msg = msg .. string.format("\n💡 Tips: Ta en RAM-dump (%s) for å fryse arbeidsminnet!", key)
    end
    vim.notify(msg, vim.log.levels.INFO, { title = "Tether Pause" })
  end
end

---Veksler tilstand (Idle -> Fokus -> Pause -> Idle)
function M.toggle()
  if M.state == M.STATE_IDLE then
    M.start_focus()
  elseif M.state == M.STATE_FOCUS then
    M.start_break()
  elseif M.state == M.STATE_BREAK then
    M.reset()
  end
end

---Nullstiller timeren og lukker vinduet
function M.reset()
  M.stop_timer()
  M.state = M.STATE_IDLE
  M.elapsed_focus_sec = 0
  M.remaining_break_sec = 0
  M.start_epoch = 0
  M.break_duration_sec = 0
  broadcast_state()
  ui.close()

  if config.options.notifications.enabled then
    vim.notify("Flowmodoro nullstilt.", vim.log.levels.INFO, { title = "Tether" })
  end
end

---Toggler synligheten til HUD-vinduet
function M.toggle_hud()
  local is_visible = ui.toggle_visibility()
  if is_visible and M.state ~= M.STATE_IDLE then
    tick()
  end
end

---Henter gjeldende status for statuslinje/lualine
---@return table
function M.get_status()
  local time_str = ""
  if M.state == M.STATE_FOCUS then
    time_str = format_time(M.elapsed_focus_sec)
  elseif M.state == M.STATE_BREAK then
    time_str = format_time(M.remaining_break_sec)
  end

  return {
    state = M.state,
    time = time_str,
    is_active = M.state ~= M.STATE_IDLE,
  }
end

return M
