#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT_DIR/Makefile
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/tweep-make-authority-XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM
CONTROL_DIR=$TEMP_ROOT/control
ATTACKER_ROOT=$TEMP_ROOT/attacker
MARKER=$TEMP_ROOT/make-syntax-expanded
LEGACY_MARKER=$TEMP_ROOT/legacy-make-syntax-expanded
PYTHON_LOG=$TEMP_ROOT/python.log
mkdir -p "$CONTROL_DIR" "$ATTACKER_ROOT"

run_make() { (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" "$@"); }

fake_python=$TEMP_ROOT/python-safe
cat >"$fake_python" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$PYTHON_LOG"
exit 0
EOF
chmod +x "$fake_python"

: >"$PYTHON_LOG"
run_make lint ROOT="$ATTACKER_ROOT" PYTHON="$fake_python" >/dev/null
grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null
if grep -F "$ATTACKER_ROOT" "$PYTHON_LOG" >/dev/null; then echo "ROOT redirected verification" >&2; exit 1; fi

: >"$PYTHON_LOG"
run_make lint SHELL=/bin/false PYTHON="$fake_python" >/dev/null
grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null

set +e
run_make lint "PYTHON=\$(shell /usr/bin/touch '$MARKER')python3" >"$TEMP_ROOT/python.out" 2>"$TEMP_ROOT/python.err"
status=$?
set -e
if [ "$status" -eq 0 ] || [ -e "$MARKER" ]; then echo "Make-syntax PYTHON was not rejected" >&2; exit 1; fi
grep -F "PYTHON must be a literal executable path" "$TEMP_ROOT/python.err" >/dev/null

for value in yes "\$(shell /usr/bin/touch '$LEGACY_MARKER')1"; do
  set +e
  run_make lint RUN_LEGACY_XCODE="$value" >"$TEMP_ROOT/legacy.out" 2>"$TEMP_ROOT/legacy.err"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then echo "unsafe RUN_LEGACY_XCODE was not rejected" >&2; exit 1; fi
done
if [ -e "$LEGACY_MARKER" ]; then echo "Make-syntax RUN_LEGACY_XCODE was expanded" >&2; exit 1; fi
grep -F "RUN_LEGACY_XCODE must be the literal value 0 or 1" "$TEMP_ROOT/legacy.err" >/dev/null

set +e
run_make lint MAKEFLAGS=--just-print >"$TEMP_ROOT/flags.out" 2>"$TEMP_ROOT/flags.err"; status=$?
set -e
if [ "$status" -eq 0 ]; then echo "MAKEFLAGS was not rejected" >&2; exit 1; fi
grep -F "MAKEFLAGS must not be overridden" "$TEMP_ROOT/flags.err" >/dev/null

startup=$TEMP_ROOT/startup.mk
printf '%s\n' 'STARTUP_FILE_LOADED := yes' >"$startup"
set +e
(cd "$CONTROL_DIR" && MAKEFILES="$startup" /usr/bin/make --no-print-directory -f "$MAKEFILE" lint) >"$TEMP_ROOT/startup.out" 2>"$TEMP_ROOT/startup.err"; status=$?
set -e
if [ "$status" -eq 0 ]; then echo "MAKEFILES was not rejected" >&2; exit 1; fi
grep -F "MAKEFILES must be empty" "$TEMP_ROOT/startup.err" >/dev/null

set +e
run_make lint PYTHON="$fake_python" MAKEFILE_LIST="$TEMP_ROOT/attacker.mk" >"$TEMP_ROOT/list.out" 2>"$TEMP_ROOT/list.err"; status=$?
set -e
if [ "$status" -eq 0 ]; then echo "MAKEFILE_LIST was not rejected" >&2; exit 1; fi
grep -F "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/list.err" >/dev/null

printf '%s\n' "Make authority tests passed: root, shell, Python, legacy-Xcode opt-in, MAKEFLAGS, MAKEFILES, and MAKEFILE_LIST"
