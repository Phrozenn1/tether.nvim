local config = require("tether.config")

local M = {}

---Fanger en strøtanke eller et sidespor umiddelbart uten å miste kontekst
function M.capture()
  vim.ui.input({
    prompt = " 󰄬 Tether Side-Quest (Impuls): ",
  }, function(input)
    if not input or input:match("^%s*$") then
      return
    end

    local file_path = vim.fn.expand(config.options.impulse.file)
    local dir = vim.fn.fnamemodify(file_path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end

    local timestamp = os.date("%Y-%m-%d %H:%M")
    local line = string.format("- [%s] %s\n", timestamp, input)

    local f = io.open(file_path, "a")
    if f then
      f:write(line)
      f:close()
      if config.options.notifications.enabled then
        vim.notify("Side-quest forankret! ⚓ Arbeidsminnet er avlastet, tilbake til flyten.", vim.log.levels.INFO, {
          title = "Tether Impulse",
        })
      end
    else
      vim.notify("Kunne ikke skrive til impuls-fil: " .. file_path, vim.log.levels.ERROR, { title = "Tether" })
    end
  end)
end

---Åpner impuls-filen i en split for gjennomgang
function M.open_list()
  local file_path = vim.fn.expand(config.options.impulse.file)
  vim.cmd("split " .. vim.fn.fnameescape(file_path))
end

return M
