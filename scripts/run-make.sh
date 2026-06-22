#!/bin/sh
set -eu

case $#:$1 in
  1:check|1:lint) ;;
  *)
    echo "usage: $0 check|lint" >&2
    exit 64
    ;;
esac

SCRIPT_PATH=$0
LINK_COUNT=0
while [ -L "$SCRIPT_PATH" ]; do
  LINK_COUNT=$((LINK_COUNT + 1))
  if [ "$LINK_COUNT" -gt 40 ]; then
    echo "run-make.sh: symlink resolution exceeded 40 links" >&2
    exit 1
  fi
  SCRIPT_DIR=$(CDPATH='' cd -- "$(/usr/bin/dirname -- "$SCRIPT_PATH")" && /bin/pwd -P)
  LINK_VALUE=$(/usr/bin/readlink -n -- "$SCRIPT_PATH"; printf x)
  LINK_VALUE=${LINK_VALUE%x}
  case $LINK_VALUE in
    /*) SCRIPT_PATH=$LINK_VALUE ;;
    *) SCRIPT_PATH=$SCRIPT_DIR/$LINK_VALUE ;;
  esac
done

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "run-make.sh: physical script path is not a regular file" >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH='' cd -- "$(/usr/bin/dirname -- "$SCRIPT_PATH")" && /bin/pwd -P)
ROOT_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && /bin/pwd -P)
if [ ! -f "$ROOT_DIR/Makefile" ]; then
  echo "run-make.sh: repository Makefile is missing" >&2
  exit 1
fi

exec /usr/bin/env \
  -u MAKEFILES \
  -u MAKEFLAGS \
  -u MFLAGS \
  -u MAKEOVERRIDES \
  -u GNUMAKEFLAGS \
  /usr/bin/make --no-print-directory -f "$ROOT_DIR/Makefile" "$1"
