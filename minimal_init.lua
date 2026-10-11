-- Minimal Neovim configuration for the tests (`nvim -u minimal_init.lua`, run
-- by run.sh with XDG_* pointing into `.deps/xdg/`, so nothing from the user's
-- own config, plugins or parsers is loaded):
--   - refactoring.nvim and its dependencies, cloned once into `.deps/` at the
--     commits below (the expected results depend on them, e.g. upstream's line
--     numbers in error messages);
--   - the Kotlin Tree-sitter parser, installed with nvim-treesitter (needs the
--     `tree-sitter` CLI and a C compiler);
--   - kotlin-lsp (from PATH) for Kotlin buffers;
--   - the plugin under test: `$PLUGIN_DIR`, by default `../refactoring-kotlin.nvim`.

local test_dir = vim.fs.dirname(vim.fs.normalize(debug.getinfo(1, "S").source:sub(2)))
local deps_dir = test_dir .. "/.deps"
local plugin_dir = vim.fs.normalize(vim.env.PLUGIN_DIR or (test_dir .. "/../refactoring-kotlin.nvim"))

local dependencies = {
  {
    name = "refactoring.nvim",
    url = "https://github.com/ThePrimeagen/refactoring.nvim",
    commit = "684b3484796ea44595bebbfddee4fa4dbfc90939",
  },
  {
    name = "async.nvim",
    url = "https://github.com/lewis6991/async.nvim",
    commit = "15f28ec323a75f34f317336831c00c2d1b0a7192",
  },
  {
    name = "nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter",
    commit = "1a4f47b03dfe92d28de7d5654c67327ef008c9e6",
  },
}

local function git(args)
  local result = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
  if result.code ~= 0 then error(("git %s failed:\n%s"):format(table.concat(args, " "), result.stderr)) end
  return vim.trim(result.stdout)
end

-- Clones the dependency, or moves it to the pinned commit if it's elsewhere.
local function install(dependency)
  local dir = deps_dir .. "/" .. dependency.name
  if vim.fn.isdirectory(dir) == 0 then
    io.stdout:write(("Cloning %s\n"):format(dependency.url))
    git({ "clone", "--filter=blob:none", "--quiet", dependency.url, dir })
  end
  if git({ "-C", dir, "rev-parse", "HEAD" }) ~= dependency.commit then
    git({ "-C", dir, "fetch", "--quiet", "origin" })
    git({ "-C", dir, "checkout", "--quiet", dependency.commit })
  end
  vim.opt.runtimepath:prepend(dir)
end

if vim.fn.isdirectory(plugin_dir) == 0 then
  error(("plugin not found in %s (set PLUGIN_DIR)"):format(plugin_dir))
end

for _, dependency in ipairs(dependencies) do
  install(dependency)
end
vim.opt.runtimepath:prepend(plugin_dir)

-- Kotlin's official style (Neovim's Kotlin ftplugin doesn't set it).
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.swapfile = false

require("nvim-treesitter").setup({ install_dir = deps_dir .. "/site" })
if not vim.list_contains(require("nvim-treesitter").get_installed(), "kotlin") then
  io.stdout:write("Installing the Kotlin Tree-sitter parser\n")
  require("nvim-treesitter").install({ "kotlin" }):wait(300000)
end

vim.lsp.config("kotlin_lsp", {
  cmd = { "kotlin-lsp", "--stdio" },
  filetypes = { "kotlin" },
  root_markers = { "settings.gradle.kts", "settings.gradle", "build.gradle.kts", "build.gradle", "pom.xml" },
})
vim.lsp.enable("kotlin_lsp")

require("refactoring").setup({})
require("refactoring-kotlin").setup()
