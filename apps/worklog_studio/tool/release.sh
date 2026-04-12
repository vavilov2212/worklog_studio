#!/bin/bash

set -e

PROJECT_DIR="$(pwd)"
APP_NAME="worklog_studio"
DMG_NAME="dmg/worklogStudio.dmg"
APPCAST_PATH="release/appcast.xml"

echo "🚀 Starting release..."

# -----------------------------
# 1. Обновление версии
# -----------------------------

VERSION_LINE=$(grep '^version:' pubspec.yaml)
CURRENT_VERSION=$(echo $VERSION_LINE | sed 's/version: //')

NAME=$(echo $CURRENT_VERSION | cut -d+ -f1)
BUILD=$(echo $CURRENT_VERSION | cut -d+ -f2)

 # Split semantic version
MAJOR=$(echo $NAME | cut -d. -f1)
MINOR=$(echo $NAME | cut -d. -f2)
PATCH=$(echo $NAME | cut -d. -f3)

TYPE=$1

# If first argument is a manual version like 1.2.3
if [[ "$TYPE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  NEW_NAME="$TYPE"
else
  if [ "$TYPE" = "major" ]; then
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
  elif [ "$TYPE" = "minor" ]; then
    MINOR=$((MINOR + 1))
    PATCH=0
  else
    # default = patch
    PATCH=$((PATCH + 1))
  fi

  NEW_NAME="$MAJOR.$MINOR.$PATCH"
fi

# Increment build
NEW_BUILD=$((BUILD + 1))

NEW_VERSION="$NEW_NAME+$NEW_BUILD"

echo "📦 Version: $NEW_VERSION"

sed -i '' "s/version: .*/version: $NEW_VERSION/" pubspec.yaml

# -----------------------------
# 2. Build
# -----------------------------

flutter build macos

# -----------------------------
# 3. Prepare dmg folder
# -----------------------------

rm -rf dmg
mkdir dmg
mkdir dmg/tmp

cp -R build/macos/Build/Products/Release/$APP_NAME.app dmg/tmp/
ln -s /Applications dmg/tmp/Applications

# -----------------------------
# 4. Create dmg
# -----------------------------

hdiutil create -volname "Worklog Studio" \
  -srcfolder dmg/tmp \
  -ov -format UDZO $DMG_NAME

rm -rf dmg/tmp

# -----------------------------
# 5. Sign dmg
# -----------------------------

SIGN_TOOL=$(find ~/Library/Developer/Xcode/DerivedData -name sign_update | head -n 1)

if [ -z "$SIGN_TOOL" ]; then
  echo "❌ sign_update not found"
  exit 1
fi

SIGN_OUTPUT=$($SIGN_TOOL $DMG_NAME)

# Extract only the edSignature value (avoid picking up file size or other numbers)
SIGNATURE=$(echo "$SIGN_OUTPUT" | grep "sparkle:edSignature" | awk -F '"' '{print $2}')

echo "🔐 Signature: $SIGNATURE"

# -----------------------------
# 6. File size
# -----------------------------

FILE_SIZE=$(stat -f%z $DMG_NAME)

echo "📏 Size: $FILE_SIZE"

# -----------------------------
# 7. Update appcast
# -----------------------------

SHORT_VERSION=$(echo $NEW_NAME)
BUILD_VERSION=$NEW_BUILD

cat > $APPCAST_PATH <<EOL
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
    xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel>
  <title>Worklog Studio Updates</title>
  <link>https://example.com/updates</link>
  <description>Latest updates for Worklog Studio</description>
  <language>en</language>

  <item>
    <title>Version $SHORT_VERSION</title>
    <sparkle:releaseNotesLink>https://example.com/updates/release-notes-1.0.1.html</sparkle:releaseNotesLink>
    <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>

    <enclosure
      url="http://localhost:3000/$DMG_NAME"
      sparkle:version="$BUILD_VERSION"
      sparkle:shortVersionString="$SHORT_VERSION"
      sparkle:edSignature="$SIGNATURE"
      length="$FILE_SIZE"
      type="application/octet-stream"/>
  </item>

</channel>
</rss>
EOL

echo "✅ appcast updated"

echo "🎉 Release ready!"