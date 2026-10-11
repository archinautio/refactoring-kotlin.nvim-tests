#!/usr/bin/env bash
# Runs the refactoring.nvim Kotlin test battery (see README.md).
#
#   ./run.sh                  run every case and compile every result
#   ./run.sh inline_func      only the cases whose name matches (a Lua pattern)
#   ./run.sh --no-compile     skip the Gradle compilation of the results
#   ./run.sh --update         save the results as the new expected ones
#
# The plugin under test is $PLUGIN_DIR, by default ../refactoring-kotlin.nvim.
set -uo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out="$dir/.out"
update=0
compile=1
filter=""
for arg in "$@"; do
  case "$arg" in
    --update) update=1 ;;
    --no-compile) compile=0 ;;
    -h | --help)
      sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) filter="$arg" ;;
  esac
done

for tool in nvim kotlin-lsp git tree-sitter; do
  command -v "$tool" >/dev/null || { echo "$tool not found in PATH" >&2; exit 2; }
done

rm -rf "$out"
mkdir -p "$out"

# Formatting: StyLua with refactoring.nvim's configuration (`.stylua.toml` in
# both repos), so code can be ported upstream as is. A failure fails the run,
# but the tests still run.
plugin_dir="${PLUGIN_DIR:-$dir/../refactoring-kotlin.nvim}"
format_failed=0
echo "== Formatting (StyLua)"
if command -v stylua >/dev/null; then
  for repo in "$plugin_dir" "$dir"; do
    if (cd "$repo" && stylua --check . >/dev/null 2>&1); then
      echo "ok   $repo"
    else
      echo "FAIL $repo (run \`stylua .\` there)"
      format_failed=1
    fi
  done
else
  echo "SKIP stylua not found"
fi
echo

# Neovim only sees minimal_init.lua: the user's config, plugins and parsers stay
# out (XDG_* point into .deps/xdg, which also keeps the installed parser).
export XDG_CONFIG_HOME="$dir/.deps/xdg/config" XDG_DATA_HOME="$dir/.deps/xdg/data"
export XDG_STATE_HOME="$dir/.deps/xdg/state" XDG_CACHE_HOME="$dir/.deps/xdg/cache"
nvim_test() { nvim --headless -u "$dir/minimal_init.lua" "$@"; }

# 0. Dependencies (cloned and the parser installed on the first run only).
echo "== Dependencies"
if ! nvim_test -c 'qall!' </dev/null; then
  echo "Couldn't prepare the dependencies (see the error above)" >&2
  exit 2
fi
echo  # nvim-treesitter's messages don't end with a newline
echo "ok"
echo

# 1. Refactors, in a headless Neovim with the user's config. A watchdog kills it
#    if it hangs (e.g. kotlin-lsp never answers). Neovim's own errors (e.g.
#    stack traces of upstream crashes, which the runner records anyway) go to
#    .out/nvim.log.
echo "== Refactoring (headless Neovim + kotlin-lsp)"
(
  cd "$dir/project" &&
    TEST_DIR="$dir" OUT_DIR="$out/results" UPDATE="$update" FILTER="$filter" \
      exec nvim --headless -u "$dir/minimal_init.lua" -c "luafile $dir/runner.lua" </dev/null 2>"$out/nvim.log"
) &
nvim_pid=$!
(
  for _ in $(seq 1200); do
    sleep 1
    kill -0 "$nvim_pid" 2>/dev/null || exit 0
  done
  echo "Timed out after 20 minutes" >&2
  kill "$nvim_pid"
) &
wait "$nvim_pid"
status=$?
wait
if [[ $status != 0 && -s "$out/nvim.log" ]]; then
  echo "-- last lines of $out/nvim.log:"
  tail -n 20 "$out/nvim.log"
fi

# 2. Every result must still be valid Kotlin: compile the project with each
#    case's changed files.
if [[ $compile == 1 && -d "$out/results" ]]; then
  echo
  echo "== Compiling the results (Gradle)"
  compile_dir="$out/compile"
  mkdir -p "$compile_dir"
  cp -R "$dir/project/"{build.gradle.kts,settings.gradle.kts,gradle.properties} "$compile_dir/"
  gradle() { "$dir/project/gradlew" -p "$compile_dir" compileKotlin --quiet --console=plain 2>&1; }

  compile_failed=()
  for case_dir in "$out/results"/*/; do
    case_name=$(basename "$case_dir")
    if [[ -f "$case_dir.skip-compile" ]]; then
      echo "SKIP $case_name ($(cat "$case_dir.skip-compile"))"
      continue
    fi
    shopt -s nullglob
    changed=("$case_dir"*.kt)
    shopt -u nullglob
    if [[ ${#changed[@]} == 0 ]]; then
      echo "SKIP $case_name (nothing changed)"
      continue
    fi
    rm -rf "$compile_dir/src"
    cp -R "$dir/project/src" "$compile_dir/src"
    cp "${changed[@]}" "$compile_dir/src/main/kotlin/"
    if output=$(gradle); then
      echo "PASS $case_name"
    else
      echo "FAIL $case_name"
      echo "$output" | grep -E '^e: |What went wrong' -A1 | sed 's/^/  /'
      compile_failed+=("$case_name")
    fi
  done
  if [[ ${#compile_failed[@]} -gt 0 ]]; then
    echo "Didn't compile: ${compile_failed[*]}"
    status=1
  fi
fi

if [[ $format_failed == 1 ]]; then
  echo
  echo "Not formatted with StyLua (see above)"
  status=1
fi

echo
if [[ $status == 0 ]]; then echo "ALL PASSED"; else echo "SOME TESTS FAILED (results in $out/results)"; fi
exit "$status"
