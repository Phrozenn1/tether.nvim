local config = require("tether.config")
local ui = require("tether.ui")

local M = {
  STATE_IDLE = "idle",
  STATE_FOCUS = "focus",
  STATE_BREAK = "break",

  state = "idle",
  timer = nil,
  elapsed_focus_sec = 0,
  remaining_break_sec = 0,
}

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

---Sjekker om en aktiv fokusøkt pågår
---@return boolean
function M.is_focus_active()
  return M.state == M.STATE_FOCUS
end

---Oppdaterer HUD og intern tilstand ved hver timer-tikk
local function tick()
  if M.state == M.STATE_FOCUS then
    M.elapsed_focus_sec = M.elapsed_focus_sec + 1
    local time_str = format_time(M.elapsed_focus_sec)
    local icon = config.options.hud.icons.focus or "󰔛"
    ui.render("focus", string.format("%s %s", icon, time_str), "Fokus")

  elseif M.state == M.STATE_BREAK then
    M.remaining_break_sec = M.remaining_break_sec - 1

    if M.remaining_break_sec <= 0 then
      M.state = M.STATE_IDLE
      M.stop_timer()

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
local function start_uv_timer()
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
  M.elapsed_focus_sec = 0
  start_uv_timer()

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
  M.remaining_break_sec = break_sec

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
