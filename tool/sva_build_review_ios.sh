#!/bin/sh
# Build review iOS release with stamp + optional UUID patch rebuild.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-release}"
STAGE="${2:-R1}"
FORCE_OFF="${3:-1}"
AUTO_PROBE="${4:-0}"

bash "$ROOT/tool/sva_build_stamp.sh" \
  --mode "$MODE" \
  --alarmkit-force-off "$FORCE_OFF" \
  --review 1 \
  --stage "$STAGE"

DEFINES="$ROOT/tool/sva_build_stamp.json"
if [ "$AUTO_PROBE" = "1" ]; then
  python3 - "$DEFINES" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p))
data["SVA_DIAG_AUTO_PROBE"] = "1"
json.dump(data, open(p, "w"), indent=2)
PY
fi

cd "$ROOT"
flutter build ios --release --dart-define-from-file="$DEFINES"
bash "$ROOT/tool/sva_patch_binary_uuid.sh"
flutter build ios --release --dart-define-from-file="$DEFINES"

echo "Built: $ROOT/build/ios/iphoneos/Runner.app"
dwarfdump --uuid "$ROOT/build/ios/iphoneos/Runner.app/Runner" | head -1
