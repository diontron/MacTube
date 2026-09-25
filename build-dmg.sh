#!/bin/bash
# Builds "MacTube 2.app" (Release, ad-hoc signed) and packages it as MacTube2.dmg.
# Requires Xcode. Run: ./build-dmg.sh
set -euo pipefail
cd "$(dirname "$0")"

rm -rf build MacTube2.dmg
xcodebuild -project MacTube.xcodeproj -target MacTube -configuration Release \
  SYMROOT="$PWD/build" CODE_SIGN_IDENTITY=- build

mkdir -p build/dmg
cp -R "build/Release/MacTube 2.app" build/dmg/
ln -s /Applications build/dmg/Applications
hdiutil create -volname "MacTube 2" -srcfolder build/dmg -ov -format UDZO MacTube2.dmg

echo "Done: $PWD/MacTube2.dmg"
