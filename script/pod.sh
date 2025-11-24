flutter clean
cd ios
pod deintegrate
rm Podfile.lock
flutter pub get
pod install --repo-update
cd ..