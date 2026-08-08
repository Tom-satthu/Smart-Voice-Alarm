#!/bin/sh
# Patch binary UUID into generated stamp after flutter build.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/ios/iphoneos/Runner.app/Runner"
GEN="$ROOT/ios/Runner/SvaBuildStamp.generated.swift"
if [ ! -f "$APP" ]; then
  echo "No built Runner binary at $APP" >&2
  exit 1
fi
UUID=$(dwarfdump --uuid "$APP" 2>/dev/null | awk '/UUID:/ {print $2; exit}')
if [ -z "$UUID" ]; then
  echo "Could not read binary UUID" >&2
  exit 1
fi
python3 - "$GEN" "$UUID" <<'PY'
import sys
path, uuid = sys.argv[1], sys.argv[2]
text = open(path).read()
text = text.replace('static let binaryUuid = "pending"', f'static let binaryUuid = "{uuid}"')
text = text.replace('static let binaryUuid = "unknown"', f'static let binaryUuid = "{uuid}"')
# replace any existing uuid line
import re
text = re.sub(
    r'static let binaryUuid = "[^"]*"',
    f'static let binaryUuid = "{uuid}"',
    text,
)
open(path, 'w').write(text)
print(f"BINARY_UUID={uuid}")
PY
