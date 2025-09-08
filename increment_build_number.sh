#!/bin/bash
# Fail-safe: do not fail the build if anything goes wrong here
set -u

echo "=== Timbrz Version Management Script ==="
echo "pwd: $(pwd)"
echo "SRCROOT: ${SRCROOT:-}" || true

echo "Environment summary:"
echo "  TARGET_NAME=${TARGET_NAME:-}"
echo "  CONFIGURATION=${CONFIGURATION:-}"
echo "  INFOPLIST_FILE=${INFOPLIST_FILE:-}"
echo "  TARGET_BUILD_DIR=${TARGET_BUILD_DIR:-}"
echo "  INFOPLIST_PATH=${INFOPLIST_PATH:-}"

# Default SRCROOT when not provided (e.g., running locally)
if [[ -z "${SRCROOT:-}" ]]; then
  SRCROOT="$(pwd)"
fi

resolve_plist_path() {
  local candidate="$1"
  if [[ -z "$candidate" ]]; then
    return 1
  fi
  # If path is absolute and exists
  if [[ "$candidate" = /* ]] && [[ -f "$candidate" ]]; then
    printf "%s" "$candidate"
    return 0
  fi
  # Try relative to SRCROOT
  if [[ -f "${SRCROOT}/$candidate" ]]; then
    printf "%s" "${SRCROOT}/$candidate"
    return 0
  fi
  return 1
}

INFOPLIST=""

# Prefer source Info.plist from build setting
if [[ -n "${INFOPLIST_FILE:-}" ]]; then
  if resolved=$(resolve_plist_path "$INFOPLIST_FILE"); then
    INFOPLIST="$resolved"
  fi
fi

# Fallback: try an app-named Info.plist at repo root
if [[ -z "$INFOPLIST" ]]; then
  for guess in "${TARGET_NAME:-Timbrz}-Info.plist" "Info.plist"; do
    if [[ -f "${SRCROOT}/$guess" ]]; then
      INFOPLIST="${SRCROOT}/$guess"
      break
    fi
  done
fi

find_project_dir() {
  # Prefer root-level projects
  local candidate
  candidate=$(ls -1 "$SRCROOT"/*.xcodeproj 2>/dev/null | head -n1 || true)
  if [[ -n "$candidate" ]]; then
    dirname "$candidate"
    return 0
  fi
  # Search recursively for the first .xcodeproj
  candidate=$(find "$SRCROOT" -type d -name "*.xcodeproj" -print -quit 2>/dev/null || true)
  if [[ -n "$candidate" ]]; then
    dirname "$candidate"
    return 0
  fi
  return 1
}

PROJ_DIR=""
if PROJ_DIR=$(find_project_dir); then
  echo "Discovered Xcode project at: $PROJ_DIR"
fi

NEW_BUILD_FROM_AGV=""
if [[ -n "$PROJ_DIR" && -d "$PROJ_DIR" ]] && ls "$PROJ_DIR"/*.xcodeproj >/dev/null 2>&1; then
  echo "Bumping CURRENT_PROJECT_VERSION via agvtool in: $PROJ_DIR"
  (cd "$PROJ_DIR" && agvtool bump -all)
  NEW_BUILD_FROM_AGV=$(cd "$PROJ_DIR" && agvtool what-version -terse 2>/dev/null | tail -n1 | tr -d '\r')
  echo "agvtool reports CURRENT_PROJECT_VERSION=${NEW_BUILD_FROM_AGV}"
fi

if [[ -n "$INFOPLIST" ]]; then
  echo "Using Info.plist at: ${INFOPLIST}"
  # Ensure version keys exist
  MARKETING_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST" 2>/dev/null || true)
  if [[ -z "${MARKETING_VERSION}" ]]; then
    MARKETING_VERSION="1.0.0"
    echo "CFBundleShortVersionString missing; defaulting to ${MARKETING_VERSION}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${MARKETING_VERSION}" "$INFOPLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${MARKETING_VERSION}" "$INFOPLIST"
  fi

  if [[ -n "$NEW_BUILD_FROM_AGV" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${NEW_BUILD_FROM_AGV}" "$INFOPLIST"
    echo "Synchronized CFBundleVersion in Info.plist to ${NEW_BUILD_FROM_AGV}"
    echo "MARKETING_VERSION=${MARKETING_VERSION}" > "${SRCROOT}/versions.env"
    echo "CURRENT_PROJECT_VERSION=${NEW_BUILD_FROM_AGV}" >> "${SRCROOT}/versions.env"
  else
    echo "[versioning] Warning: No .xcodeproj found for agvtool fallback. Set INFOPLIST_FILE or ensure project path."
  fi
fi

if [[ -z "$INFOPLIST" || ! -f "$INFOPLIST" ]]; then
  echo "[versioning] Could not determine source Info.plist path. Attempting agvtool fallback..."
  # Try bumping build number via agvtool (works with synthesized Info.plist when CURRENT_PROJECT_VERSION is set)
  PROJ_DIR="$SRCROOT"
  if ! ls "$PROJ_DIR"/*.xcodeproj >/dev/null 2>&1; then
    if ls "$SRCROOT/Timbrz"/*.xcodeproj >/dev/null 2>&1; then
      PROJ_DIR="$SRCROOT/Timbrz"
    fi
  fi
  if ls "$PROJ_DIR"/*.xcodeproj >/dev/null 2>&1; then
    (cd "$PROJ_DIR" && agvtool bump -all) || echo "[versioning] agvtool bump failed (continuing)"
    echo "[versioning] agvtool bump completed."
  else
    echo "[versioning] Warning: No .xcodeproj found for agvtool fallback. Set INFOPLIST_FILE in target or place project at $SRCROOT or $SRCROOT/Timbrz."
  fi
fi

if [[ -n "$INFOPLIST" && -f "$INFOPLIST" ]]; then
  BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST" 2>/dev/null || true)
  if [[ -z "${BUILD_NUMBER}" ]]; then
    BUILD_NUMBER="0"
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${BUILD_NUMBER}" "$INFOPLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "$INFOPLIST"
  fi
  BUILD_NUMBER_NUMERIC=$(echo "$BUILD_NUMBER" | sed 's/[^0-9].*$//')
  if [[ -z "$BUILD_NUMBER_NUMERIC" ]]; then
    BUILD_NUMBER_NUMERIC=0
  fi
  NEW_BUILD_NUMBER=$((BUILD_NUMBER_NUMERIC + 1))
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${NEW_BUILD_NUMBER}" "$INFOPLIST"
  echo "MARKETING_VERSION=${MARKETING_VERSION:-}" > "${SRCROOT}/versions.env"
  echo "CURRENT_PROJECT_VERSION=${NEW_BUILD_NUMBER}" >> "${SRCROOT}/versions.env"
  echo "[versioning] Updated build: ${BUILD_NUMBER} -> ${NEW_BUILD_NUMBER}"
  exit 0
fi

echo "[versioning] Warning: Could not locate Info.plist or Xcode project to bump version. No changes made."
exit 0
