flutter clean
flutter pub get
flutter build apk --debug
&"$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install android/app/build/outputs/apk/debug/app-debug.apk
