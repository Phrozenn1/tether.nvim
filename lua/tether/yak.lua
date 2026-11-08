local config = require("tether.config")
local flowmodoro = require("tether.flowmodoro")

local M = {
  last_triggered = 0,
}

---Sjekker om en filsti matcher dotfiles eller konfigurasjonsfiler
---@param path string
---@return boolean
local function is_config_file(path)
  if not path or path == "" then
    return false
  end

  local patterns = config.options.yak_shaving.config_patterns or {}
  for _, pat in ipairs(patterns) do
    if path:match(pat) then
      return true
    end
  end
  return false
end

---Velger et tilfeldig sarkastisk stikk
---@return string
local function get_random_jab()
  local jabs = config.options.yak_shaving.jabs
  if not jabs or #jabs == 0 then
    return "Er du i ferd med å barbere en jak? Husk hovedmålet for økten!"
  end
  local idx = math.random(1, #jabs)
  return jabs[idx]
end

---Sjekker gjeldende buffer og utløser varsel hvis det er et sidespor i fokus-tid
---@param bufnr? number
function M.check_buffer(bufnr)
  local cfg = config.options.yak_shaving
  if not cfg.enabled then
    return
  end

  -- Kun relevant dersom en fokus-økt faktisk er aktiv
  if not flowmodoro.is_focus_active() then
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)

  if is_config_file(buf_name) then
    local now = os.time()
    local throttle = cfg.throttle_seconds or 300

    if now - M.last_triggered >= throttle then
      M.last_triggered = now
      local jab = get_random_jab()

      vim.notify(jab, vim.log.levels.WARN, {
        title = "Tether: Yak-Shaving Alarm 🪒",
        timeout = 7000,
      })
    end
  end
end

return M
