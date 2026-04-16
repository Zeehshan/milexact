#!/bin/bash

#########################
# QURAN_KIDS
# Clear temporary data, update plugins
#
# Requirements (packages): bash, fluttersdk
# Run (command line): cd <QURAN_KIDS_ROOT_DIR> && ./clear_environments.sh
# NOTE: script is tested using mac
#########################

# exit when any command fails
set -e

echo "Clear iOS working/development environment (CLOSE XCODE FIRST!!!)"

echo -ne "Delete project's temp files located at ~/Library/Developer/Xcode/DerivedData... "
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "finished."

echo -ne "Delete project file..."
rm -rf ios/Runner.xcworkspace
echo "finished."

echo -ne "Delete Podfile.lock and Pods..."
rm -rf ios/Podfile.lock ios/Pods
echo "finished."

echo "Flutter clean..."
flutter clean
echo "finished."

echo "Flutter pub get..."
flutter pub get
echo "finished."

echo "Installing Pods..."
# cd ios/ && arch -x86_64 pod install --repo-update # Apple M1
cd ios/ && pod install --repo-update # Intel
echo "finished."

#echo "Generating models..." # TODO
#cd ../ && dart pub run build_runner build --delete-conflicting-outputs
#echo "finished."


echo "Process finished with exit code 0"
exit 0

