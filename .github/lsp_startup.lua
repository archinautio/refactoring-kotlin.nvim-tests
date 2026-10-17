-- Measures kotlin-lsp's startup: from spawning it until it answers
-- textDocument/definition and textDocument/references correctly for a symbol
-- defined in another file (same readiness check as runner.lua).
-- Usage: nvim --clean --headless -l lsp_startup.lua <project dir>
local project = vim.fn.fnamemodify(assert(arg[1], "project dir"), ":p"):gsub("/$", "")
local file = project .. "/src/main/kotlin/CrossFileUsage.kt"
local line_text, word, want_refs = "val reduced = discount(amount)", "discount", 3

local t0 = vim.uv.hrtime()
local function since() return (vim.uv.hrtime() - t0) / 1e9 end
local function log(fmt, ...) io.stdout:write(("[%7.2fs] " .. fmt .. "\n"):format(since(), ...)) end

vim.cmd.edit(file)
local buf = vim.api.nvim_get_current_buf()
vim.bo[buf].filetype = "kotlin"
local lnum = vim.fn.search("\\V" .. line_text) -- 1-based
local col = vim.fn.getline(lnum):find(word, 1, true) - 1
local pos = { textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = lnum - 1, character = col } }

local marks = {}
local function mark(name)
  if not marks[name] then
    marks[name] = since()
    log("%s", name)
  end
end

t0 = vim.uv.hrtime()
local client_id = vim.lsp.start({
  name = "kotlin_lsp",
  cmd = { "kotlin-lsp", "--stdio" },
  root_dir = project,
  on_init = function() mark "initialize response" end,
  handlers = {
    ["$/progress"] = function(_, result)
      local v = result.value or {}
      log("progress %s %s %s", v.kind or "", v.title or "", v.message or "")
    end,
  },
}, { bufnr = buf })
assert(client_id, "kotlin-lsp didn't start")
mark "spawned"

local ok = vim.wait(600000, function()
  local client = vim.lsp.get_client_by_id(client_id)
  if not client or not client.initialized then return false end
  local def = vim.lsp.buf_request_sync(buf, "textDocument/definition", pos, 30000) or {}
  local defword
  for _, r in pairs(def) do
    local res = r.result
    if res and res[1] then res = res[1] end
    local range = res and (res.targetSelectionRange or res.range)
    local uri = res and (res.uri or res.targetUri)
    if uri and range then
      mark "first definition answer"
      local l = vim.fn.readfile(vim.uri_to_fname(uri))[range.start.line + 1] or ""
      defword = l:sub(range.start.character + 1):match "^[%w_]+"
    end
  end
  local refparams = vim.tbl_extend("force", pos, { context = { includeDeclaration = true } })
  local n = 0
  for _, r in pairs(vim.lsp.buf_request_sync(buf, "textDocument/references", refparams, 30000) or {}) do
    n = r.result and #r.result or n
  end
  if n > 0 then mark "first references answer" end
  return defword == word and n >= want_refs
end, 500)

if ok then
  mark "ready"
  io.stdout:write(("RESULT initialize=%.2fs ready=%.2fs\n"):format(marks["initialize response"] or -1, marks.ready))
else
  io.stdout:write "RESULT timeout (600 s)\n"
end
vim.lsp.get_client_by_id(client_id):stop()
vim.wait(10000, function() return vim.lsp.get_client_by_id(client_id) == nil end)
os.exit(ok and 0 or 1)
