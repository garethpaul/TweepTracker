#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(/usr/bin/dirname -- "$0")/.." && /bin/pwd -P)
MAKEFILE=$ROOT_DIR/Makefile
WRAPPER=$ROOT_DIR/scripts/run-make.sh
if [ -x /opt/homebrew/bin/gmake ]; then
  MAKE4=/opt/homebrew/bin/gmake
elif /usr/bin/make --version 2>/dev/null | /usr/bin/grep -q '^GNU Make 4\.'; then
  MAKE4=/usr/bin/make
elif command -v gmake >/dev/null 2>&1; then
  MAKE4=$(command -v gmake)
else
  echo "GNU Make 4.x is required for the authority regression" >&2
  exit 1
fi
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/tweep-make-wrapper-XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM
CONTROL_DIR=$TEMP_ROOT/control
ATTACKER_ROOT=$TEMP_ROOT/attacker
PYTHON_LOG=$TEMP_ROOT/python.log
mkdir -p "$CONTROL_DIR" "$ATTACKER_ROOT"

fake_python=$TEMP_ROOT/python-safe
cat >"$fake_python" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$PYTHON_LOG"
exit 0
EOF
chmod +x "$fake_python"

failing_python=$TEMP_ROOT/python-fail
cat >"$failing_python" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$PYTHON_LOG"
exit 23
EOF
chmod +x "$failing_python"

assert_raw_preparse_authority() {
  : >"$PYTHON_LOG"
  "$MAKE4" -n '--eval=override MAKEFLAGS :=' --no-print-directory -f "$MAKEFILE" lint \
    PYTHON="$fake_python" >"$TEMP_ROOT/dry-run.out" 2>"$TEMP_ROOT/dry-run.err"
  if [ -s "$PYTHON_LOG" ]; then
    echo "raw -n/--eval unexpectedly executed lint" >&2
    exit 1
  fi

  : >"$PYTHON_LOG"
  "$MAKE4" -i '--eval=override MAKEFLAGS :=' --no-print-directory -f "$MAKEFILE" lint \
    PYTHON="$failing_python" >"$TEMP_ROOT/ignore.out" 2>"$TEMP_ROOT/ignore.err"
  grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null

  : >"$PYTHON_LOG"
  GNUMAKEFLAGS='--eval=override\ MAKEFLAGS\ :=' \
    "$MAKE4" -n --no-print-directory -f "$MAKEFILE" lint PYTHON="$fake_python" \
    >"$TEMP_ROOT/gnumakeflags.out" 2>"$TEMP_ROOT/gnumakeflags.err"
  if [ -s "$PYTHON_LOG" ]; then
    echo "raw GNUMAKEFLAGS unexpectedly executed lint" >&2
    exit 1
  fi

  startup_marker=$TEMP_ROOT/startup-executed
  startup=$TEMP_ROOT/startup.mk
  cat >"$startup" <<EOF
\$(shell /usr/bin/touch '$startup_marker')
override MAKEFILES :=
EOF
  MAKEFILES="$startup" "$MAKE4" --no-print-directory -f "$MAKEFILE" lint \
    PYTHON="$fake_python" >"$TEMP_ROOT/startup.out" 2>"$TEMP_ROOT/startup.err"
  test -e "$startup_marker"

  earlier_marker=$TEMP_ROOT/earlier-file-executed
  earlier=$TEMP_ROOT/earlier.mk
  printf '%s\n' "\$(shell /usr/bin/touch '$earlier_marker')" >"$earlier"
  "$MAKE4" --no-print-directory -f "$earlier" -f "$MAKEFILE" lint PYTHON="$fake_python" \
    >"$TEMP_ROOT/earlier.out" 2>"$TEMP_ROOT/earlier.err"
  test -e "$earlier_marker"

  later_marker=$TEMP_ROOT/later-file-executed
  later=$TEMP_ROOT/later.mk
  printf '%s\n' "\$(shell /usr/bin/touch '$later_marker')" >"$later"
  "$MAKE4" --no-print-directory -f "$MAKEFILE" -f "$later" lint PYTHON="$fake_python" \
    >"$TEMP_ROOT/later.out" 2>"$TEMP_ROOT/later.err"
  test -e "$later_marker"
}

assert_rejected() {
  name=$1
  shift
  set +e
  "$WRAPPER" "$@" >"$TEMP_ROOT/$name.out" 2>"$TEMP_ROOT/$name.err"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    echo "wrapper accepted $name" >&2
    exit 1
  fi
}

assert_wrapper_boundary() {
  if [ ! -x "$WRAPPER" ]; then
    echo "sanitized Make wrapper is missing" >&2
    exit 1
  fi

  : >"$PYTHON_LOG"
  (cd "$CONTROL_DIR" && PYTHON="$fake_python" "$WRAPPER" lint) >/dev/null
  grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null

  "$MAKE4" --version | /usr/bin/head -n 1 >/dev/null

  assert_rejected missing-target
  assert_rejected extra-target lint check
  assert_rejected option --just-print
  assert_rejected assignment PYTHON="$fake_python"
  assert_rejected alternate-file -f "$MAKEFILE" lint
  assert_rejected eval --eval='override MAKEFLAGS :=' lint

  for variable in MAKEFILES MAKEFLAGS MFLAGS MAKEOVERRIDES GNUMAKEFLAGS; do
    marker=$TEMP_ROOT/$variable-executed
    startup=$TEMP_ROOT/$variable.mk
    printf '%s\n' "\$(shell /usr/bin/touch '$marker')" >"$startup"
    : >"$PYTHON_LOG"
    case $variable in
      MAKEFILES) env MAKEFILES="$startup" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null ;;
      MAKEFLAGS) env MAKEFLAGS="-f $startup" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null ;;
      MFLAGS) env MFLAGS="-f $startup" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null ;;
      MAKEOVERRIDES) env MAKEOVERRIDES="X=\$(shell /usr/bin/touch '$marker')" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null ;;
      GNUMAKEFLAGS) env GNUMAKEFLAGS="--eval=\$(shell\ /usr/bin/touch\ '$marker')" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null ;;
    esac
    if [ -e "$marker" ]; then
      echo "$variable crossed the wrapper boundary" >&2
      exit 1
    fi
    grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null
  done

  hostile_path=$TEMP_ROOT/path
  mkdir -p "$hostile_path"
  for tool in dirname pwd readlink env make; do
    cat >"$hostile_path/$tool" <<EOF
#!/bin/sh
/usr/bin/touch '$TEMP_ROOT/path-$tool-executed'
exit 99
EOF
    chmod +x "$hostile_path/$tool"
  done
  : >"$PYTHON_LOG"
  PATH="$hostile_path:/usr/bin:/bin" PYTHON="$fake_python" "$WRAPPER" lint >/dev/null
  grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null
  if find "$TEMP_ROOT" -name 'path-*-executed' -print | grep -q .; then
    echo "PATH substituted a fixed wrapper tool" >&2
    exit 1
  fi

  linked_root=$TEMP_ROOT/linked
  mkdir -p "$linked_root/scripts"
  /bin/ln -s "$WRAPPER" "$linked_root/scripts/run-make.sh"
  printf 'lint:\n\t@/usr/bin/touch "%s"\n' "\$\${ATTACKER_MARKER}" >"$linked_root/Makefile"
  : >"$PYTHON_LOG"
  PYTHON="$fake_python" ATTACKER_MARKER="$TEMP_ROOT/symlink-root-executed" \
    "$linked_root/scripts/run-make.sh" lint >/dev/null
  grep -F "$ROOT_DIR/scripts/check_ios_project.py" "$PYTHON_LOG" >/dev/null
  test ! -e "$TEMP_ROOT/symlink-root-executed"
}

assert_raw_preparse_authority
assert_wrapper_boundary
printf '%s\n' "Make wrapper tests passed: raw pre-parse authority reproduced and sanitized check/lint entrypoint enforced"
