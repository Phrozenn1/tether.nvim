local M = {}

---Finner filbanen til stats.json
function M.get_file_path()
  local state_dir = vim.fn.expand("~/.local/state/tether")
  if vim.fn.isdirectory(state_dir) == 0 then
    vim.fn.mkdir(state_dir, "p")
  end
  return state_dir .. "/stats.json"
end

local function get_week_identifier()
  return os.date("%Y-W%W")
end

local function get_today_key()
  return os.date("%Y-%m-%d")
end

---Laster inn statistikk fra stats.json
---@return table
function M.load()
  local default_stats = {
    total_focus_mins = 0,
    current_week_mins = 0,
    current_week_sessions = 0,
    current_week_impulses_captured = 0,
    week_identifier = get_week_identifier(),
    daily_mins = {},
    xp = 0,
  }

  local file_path = M.get_file_path()
  local f = io.open(file_path, "r")
  if not f then return default_stats end

  local content = f:read("*a")
  f:close()
  if not content or content == "" then return default_stats end

  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return default_stats
  end

  -- Sjekk ukerullering
  local current_week = get_week_identifier()
  if data.week_identifier ~= current_week then
    data.week_identifier = current_week
    data.current_week_mins = 0
    data.current_week_sessions = 0
    data.current_week_impulses_captured = 0
  end

  data.total_focus_mins = data.total_focus_mins or 0
  data.current_week_mins = data.current_week_mins or 0
  data.current_week_sessions = data.current_week_sessions or 0
  data.current_week_impulses_captured = data.current_week_impulses_captured or 0
  data.daily_mins = data.daily_mins or {}
  data.xp = data.xp or 0

  return data
end

---Lagrer statistikk til stats.json
---@param stats table
function M.save(stats)
  if not stats.daily_mins or not next(stats.daily_mins) then
    stats.daily_mins = (vim.empty_dict and vim.empty_dict()) or {}
  end
  local file_path = M.get_file_path()
  local f = io.open(file_path, "w")
  if f then
    f:write(vim.json.encode(stats))
    f:close()
  end
end

---Beregner tittel og neste terskel basert på XP
---@param xp number
---@return string title, number next_threshold
function M.get_tier(xp)
  if xp < 500 then
    return "⚡ Gnist", 500
  elseif xp < 2000 then
    return "🌊 Flyt-rytter", 2000
  elseif xp < 5000 then
    return "🚀 Dypdykker", 5000
  else
    return "🧙‍♂️ Flyt-mester", 10000
  end
end

---Registrerer fullførte fokus-minutter
---@param minutes number
function M.record_focus_minutes(minutes)
  if minutes <= 0 then return end
  local stats = M.load()
  stats.total_focus_mins = stats.total_focus_mins + minutes
  stats.current_week_mins = stats.current_week_mins + minutes
  stats.current_week_sessions = stats.current_week_sessions + 1

  local added_xp = minutes * 10
  stats.xp = stats.xp + added_xp

  local today = get_today_key()
  stats.daily_mins[today] = (stats.daily_mins[today] or 0) + minutes

  M.save(stats)
  return added_xp, stats.xp
end

---Registrerer fullført 5-minutters mikro-start (terskel overvunnet!)
function M.record_micro_start()
  local stats = M.load()
  stats.xp = stats.xp + 100
  M.save(stats)
end

---Registrerer en fanget impuls (kaninhull unngått!)
function M.record_impulse()
  local stats = M.load()
  stats.current_week_impulses_captured = stats.current_week_impulses_captured + 1
  stats.xp = stats.xp + 25
  M.save(stats)
end

---Viser en motiverende sammendragsnotifikasjon
function M.show_summary()
  local stats = M.load()
  local tier, next_xp = M.get_tier(stats.xp)
  local msg = string.format(
    "Nivå: %s (%d XP / %d)\nUkens flyt: %d minutter (%d økter)\nParkerte impulser: %d",
    tier,
    stats.xp,
    next_xp,
    stats.current_week_mins,
    stats.current_week_sessions,
    stats.current_week_impulses_captured
  )
  vim.notify(msg, vim.log.levels.INFO, { title = "Tether Momentum 🔥" })
end

return M
