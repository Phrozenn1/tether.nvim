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
    local format = config.options.impulse.format or "markdown_checkbox"

    if format == "json" then
      local tasks = {}
      if vim.fn.filereadable(file_path) == 1 then
        local lines = vim.fn.readfile(file_path)
        if lines and #lines > 0 then
          local ok, decoded = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
          if ok and type(decoded) == "table" then
            tasks = decoded
          end
        end
      end
      table.insert(tasks, {
        timestamp = timestamp,
        text = input,
        done = false,
      })
      local encoded = vim.fn.json_encode(tasks)
      local f = io.open(file_path, "w")
      if f then
        f:write(encoded)
        f:close()
      else
        vim.notify("Kunne ikke skrive til impuls-fil: " .. file_path, vim.log.levels.ERROR, { title = "Tether" })
        return
      end
    else
      local line = ""
      if format == "markdown_checkbox" then
        line = string.format("- [ ] [%s] %s\n", timestamp, input)
      elseif format == "todo_txt" then
        local date_only = os.date("%Y-%m-%d")
        line = string.format("(B) %s %s +sidequest\n", date_only, input)
      else -- markdown_bullet
        line = string.format("- [%s] %s\n", timestamp, input)
      end

      local f = io.open(file_path, "a")
      if f then
        f:write(line)
        f:close()
      else
        vim.notify("Kunne ikke skrive til impuls-fil: " .. file_path, vim.log.levels.ERROR, { title = "Tether" })
        return
      end
    end

    if config.options.notifications.enabled then
      vim.notify("Side-quest forankret! ⚓ Arbeidsminnet er avlastet, tilbake til flyten.", vim.log.levels.INFO, {
        title = "Tether Impulse",
      })
    end
  end)
end

---Åpner impuls-filen i en split for gjennomgang
function M.open_list()
  local file_path = vim.fn.expand(config.options.impulse.file)
  vim.cmd("split " .. vim.fn.fnameescape(file_path))
end

return M
