-- Runs the cases in cases.lua inside a headless Neovim started with
-- minimal_init.lua (refactoring.nvim, the plugin under test and kotlin-lsp).
-- Started by run.sh, which passes:
--   TEST_DIR  this directory
--   OUT_DIR   where each case's result is written (`<OUT_DIR>/<case>/`)
--   UPDATE=1  write the results as the new expected ones instead of comparing
--   FILTER    Lua pattern: only run the cases whose name matches
-- Every case writes the files it changed plus `messages.txt` (the notifications).
-- The process exits with status 1 if any case fails.

local api = vim.api

local test_dir = assert(vim.env.TEST_DIR, "TEST_DIR not set")
local out_dir = assert(vim.env.OUT_DIR, "OUT_DIR not set")
local src_dir = test_dir .. "/project/src/main/kotlin"
local expected_dir = test_dir .. "/expected"
local update = vim.env.UPDATE == "1"
local filter = vim.env.FILTER ~= "" and vim.env.FILTER or nil

local function log(...)
  io.stdout:write(table.concat(vim.tbl_map(tostring, { ... }), " ") .. "\n")
  io.stdout:flush()
end

-- Notifications are collected (and a multi-line one can't wait for <Enter>).
local messages = {}
vim.notify = function(msg)
  table.insert(messages, msg)
end
vim.o.more = false

local function read(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

local function write(path, content)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

-- 1-based row and 0-based column of the first line containing `line`, at
-- `word` (a whole word: `square` doesn't match in `squared`).
local function find(buf, line, word)
  word = word or line
  local pattern = vim.pesc(word)
  if word:match "^[%w_]" then pattern = "%f[%w_]" .. pattern end
  if word:match "[%w_]$" then pattern = pattern .. "%f[^%w_]" end
  for row, text in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local start = text:find(line, 1, true)
    if start then
      local col = text:find(pattern)
      assert(col, ("%q not found in line %q"):format(word, text))
      return row, col - 1
    end
  end
  error(("line containing %q not found"):format(line))
end

-- Text of an LSP `Location` or `LocationLink`.
local function location_text(location)
  local uri = location.targetUri or location.uri
  local range = location.targetSelectionRange or location.range
  local buf = vim.uri_to_bufnr(uri)
  vim.fn.bufload(buf)
  local start, finish = range.start, range["end"]
  local ok, lines = pcall(api.nvim_buf_get_text, buf, start.line, start.character, finish.line, finish.character, {})
  return ok and table.concat(lines, "\n") or nil
end

-- Waits until kotlin-lsp is in sync with the buffer: the definition at the
-- cursor is `word` and it reports at least `count` references (declaration
-- included). It has to finish indexing, and to catch up with the revert of the
-- previous case. The definition also proves the cursor is on the right symbol.
local function wait_for_lsp(buf, word, count)
  local attached = vim.wait(120000, function()
    return #vim.lsp.get_clients { bufnr = buf, name = "kotlin_lsp" } > 0
  end, 200)
  if not attached then error "kotlin-lsp didn't attach" end

  local params = vim.lsp.util.make_position_params(0, "utf-16")
  local definition, found = nil, 0
  local deadline = vim.uv.now() + 240000
  while vim.uv.now() < deadline do
    for _, response in pairs(vim.lsp.buf_request_sync(buf, "textDocument/definition", params, 20000) or {}) do
      local result = response.result
      if result and result[1] then result = result[1] end
      definition = result and (result.uri or result.targetUri) and location_text(result) or definition
    end
    local references = vim.tbl_extend("force", params, { context = { includeDeclaration = true } })
    for _, response in pairs(vim.lsp.buf_request_sync(buf, "textDocument/references", references, 20000) or {}) do
      found = response.result and #response.result or found
    end
    if definition == word and found >= count then return end
    vim.wait(1000)
  end
  error(
    ("kotlin-lsp: definition %q (expected %q), %d references (expected %d)"):format(
      tostring(definition),
      word,
      found,
      count
    )
  )
end

local function run(case)
  local buf = api.nvim_get_current_buf()
  local refactoring = require "refactoring"
  local keys

  if case.kind:match "^extract_" then
    -- A list for refactors that ask several things (extract_func_to_file).
    local input = type(case.input) == "table" and vim.deepcopy(case.input) or { case.input }
    keys = refactoring[case.kind] { input = input }
    if case.lines then
      local from = find(buf, case.lines.from)
      local to = find(buf, case.lines.to)
      api.nvim_win_set_cursor(0, { from, 0 })
      keys = keys .. (to > from and (to - from) .. "j" or "_")
    else
      local row, col = find(buf, case.select.line, case.select.text)
      api.nvim_win_set_cursor(0, { row, col })
      keys = keys .. "v" .. (#case.select.text > 1 and (#case.select.text - 1) .. "l" or "")
    end
  else
    local row, col = find(buf, case.at.line, case.at.word)
    api.nvim_win_set_cursor(0, { row, col })
    if case.refs then wait_for_lsp(buf, case.at.word, case.refs) end
    keys = refactoring[case.kind]()
  end

  messages = {}
  vim.v.errmsg = ""
  vim.cmd("normal " .. api.nvim_replace_termcodes(keys, true, false, true))
  -- LSP refactors are async: wait for the plugin's notification (or for an
  -- error, which async code reports through `v:errmsg`), then for the
  -- notifications to settle.
  local function crashed()
    return vim.v.errmsg ~= ""
  end
  if not vim.wait(60000, function()
    return #messages > 0 or crashed()
  end, 50) then
    error "no notification from the refactor"
  end
  local seen = -1
  vim.wait(5000, function()
    local settled = seen == #messages
    seen = #messages
    return settled
  end, 300)
  if crashed() then
    -- Recorded like a notification: first line, without directories (they
    -- depend on the machine, and long ones are truncated with `...`).
    local first_line = vim.split(vim.v.errmsg, "\n")[1]
    table.insert(messages, "Error: " .. first_line:gsub("[^%s]*/", ""))
  end
end

-- The changed buffers, as `{ [file name] = content }`.
local function changed_files()
  local files = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
      files[vim.fs.basename(api.nvim_buf_get_name(buf))] = table.concat(lines, "\n") .. "\n"
    end
  end
  return files
end

-- Puts the file contents back as a normal buffer change, which is sent to
-- kotlin-lsp like any edit. Buffers of files the refactor created are wiped.
local function revert()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      local name = api.nvim_buf_get_name(buf)
      if vim.fn.filereadable(name) == 1 then
        api.nvim_buf_set_lines(buf, 0, -1, true, vim.fn.readfile(name))
        vim.bo[buf].modified = false
      else
        api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

local cases = dofile(test_dir .. "/cases.lua")
local failed, passed, ran = {}, 0, 0
local started = vim.uv.now()

for _, case in ipairs(cases) do
  if not filter or case.name:match(filter) then
    ran = ran + 1
    vim.cmd.edit(src_dir .. "/" .. case.file)
    local ok, err = pcall(run, case)

    local result = changed_files()
    result["messages.txt"] = table.concat(messages, "\n") .. "\n"
    if not ok then result["error.txt"] = tostring(err) .. "\n" end
    revert()

    local case_out = out_dir .. "/" .. case.name
    for name, content in pairs(result) do
      write(case_out .. "/" .. name, content)
    end
    -- For run.sh (not compared with the expected results).
    if case.compiles == false then write(case_out .. "/.skip-compile", (case.reason or "") .. "\n") end

    local case_expected = expected_dir .. "/" .. case.name
    local problems = {}
    if update then
      vim.fn.delete(case_expected, "rf")
      for name, content in pairs(result) do
        write(case_expected .. "/" .. name, content)
      end
    else
      local names = {}
      for name in pairs(result) do
        names[name] = true
      end
      if vim.fn.isdirectory(case_expected) == 1 then
        for name in vim.fs.dir(case_expected) do
          names[name] = true
        end
      end
      for name in vim.spairs(names) do
        local expected, actual = read(case_expected .. "/" .. name), result[name]
        if expected ~= actual then
          local diff = vim.diff(expected or "", actual or "", { ctxlen = 2 })
          table.insert(problems, ("  %s:\n%s"):format(name, (diff:gsub("([^\n]+)", "    %1"))))
        end
      end
    end

    if not ok then table.insert(problems, 1, "  error: " .. tostring(err)) end
    if #problems == 0 then
      passed = passed + 1
      log(("PASS %s"):format(case.name))
    else
      table.insert(failed, case.name)
      log(("FAIL %s\n%s"):format(case.name, table.concat(problems, "\n")))
    end
  end
end

log(
  ("\n%d/%d passed in %.1fs%s"):format(
    passed,
    ran,
    (vim.uv.now() - started) / 1000,
    update and " (expected results updated)" or ""
  )
)
if #failed > 0 then log("Failed: " .. table.concat(failed, ", ")) end
vim.cmd(#failed > 0 and "cquit 1" or "qall!")
