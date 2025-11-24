#!/bin/bash

PUBSPEC_FILE="pubspec.yaml"

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "Error: $PUBSPEC_FILE not found!"
  exit 1
fi

PACKAGE_NAME=$(grep '^name:' "$PUBSPEC_FILE" | awk '{print $2}')
COMPANY_NAME=$(grep '^company_name:' "$PUBSPEC_FILE" | awk '{print $2}')
PACKAGE_VERSION=$(grep '^version:' "$PUBSPEC_FILE" | awk '{print $2}')
DATENOWTIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Create archives directory
ARCHIVES_DIR="ios_archives"
mkdir -p "$ARCHIVES_DIR"

# Check for existing IPA
IPA_PATH="build/ios/ipa/ipa.ipa"
if [ -f "$IPA_PATH" ]; then
    echo "Mevcut bir IPA dosyası bulundu: $IPA_PATH"
    echo -n "Mevcut IPA ile devam etmek ister misiniz? (y/n): "
    read USE_EXISTING_IPA
    if [ "$USE_EXISTING_IPA" != "y" ]; then
        echo "Yeni IPA oluşturulacak..."
        BUILD_NEW_IPA=true
    else
        echo "Mevcut IPA kullanılacak..."
        BUILD_NEW_IPA=false
    fi
else
    BUILD_NEW_IPA=true
fi

EMAIL_FILE="email.txt"
APPLE_ID_FILE="apple_id.txt"

# Check if email file exists
if [ -f "$EMAIL_FILE" ]; then
    PREVIOUS_EMAIL=$(cat "$EMAIL_FILE")
    echo "Önceki e-posta adresi bulundu: $PREVIOUS_EMAIL"
    echo -n "Bu e-posta adresi ile devam etmek ister misiniz? (y/n): "
    read USE_EXISTING_EMAIL
    if [ "$USE_EXISTING_EMAIL" != "y" ]; then
        echo -n "Yeni e-posta adresinizi girin: "
        read EMAIL
        echo "$EMAIL" > "$EMAIL_FILE"
    else
        EMAIL="$PREVIOUS_EMAIL"
    fi
else
    echo -n "E-posta adresinizi girin: "
    read EMAIL
    echo "$EMAIL" > "$EMAIL_FILE"
fi

echo "Kullanılan e-posta adresi: $EMAIL"

# Check if Apple ID file exists
if [ -f "$APPLE_ID_FILE" ]; then
    PREVIOUS_APPLE_ID=$(cat "$APPLE_ID_FILE")
    echo "Önceki Apple ID bulundu: $PREVIOUS_APPLE_ID"
    echo -n "Bu Apple ID ile devam etmek ister misiniz? (y/n): "
    read USE_EXISTING_APPLE_ID
    if [ "$USE_EXISTING_APPLE_ID" != "y" ]; then
        echo -n "Enter your Apple ID (email): "
        read APPLE_ID
        echo "$APPLE_ID" > "$APPLE_ID_FILE"
    else
        APPLE_ID="$PREVIOUS_APPLE_ID"
    fi
else
    echo -n "Enter your Apple ID (email): "
    read APPLE_ID
    echo "$APPLE_ID" > "$APPLE_ID_FILE"
fi

echo "Kullanılan Apple ID: $APPLE_ID"

echo -n "Do you want to use keychain for password storage? (y/n): "
read USE_KEYCHAIN

if [ "$USE_KEYCHAIN" = "y" ]; then
  # Check if password already exists in keychain
  if security find-generic-password -a "$APPLE_ID" -s "TESTFLIGHT_PASSWORD" > /dev/null 2>&1; then
    echo "Found existing keychain password. Do you want to use it? (y/n): "
    read USE_EXISTING
    if [ "$USE_EXISTING" = "n" ]; then
      echo -n "Enter your App-Specific Password: "
      read -s APP_SPECIFIC_PASSWORD
      echo
      # Store new password in keychain
      security add-generic-password -U -a "$APPLE_ID" -s "TESTFLIGHT_PASSWORD" -w "$APP_SPECIFIC_PASSWORD"
    fi
  else
    echo -n "Enter your App-Specific Password: "
    read -s APP_SPECIFIC_PASSWORD
    echo
    # Store password in keychain
    security add-generic-password -U -a "$APPLE_ID" -s "TESTFLIGHT_PASSWORD" -w "$APP_SPECIFIC_PASSWORD"
  fi
  PASSWORD_ARG="@keychain:TESTFLIGHT_PASSWORD"
else
  echo -n "Enter your App-Specific Password: "
  read -s APP_SPECIFIC_PASSWORD
  echo
  PASSWORD_ARG="$APP_SPECIFIC_PASSWORD"
fi

if [ "$BUILD_NEW_IPA" = true ]; then
    echo "PACKAGE_NAME: ${PACKAGE_NAME}"
    echo "PACKAGE_VERSION: ${PACKAGE_VERSION}"

    # Flutter path
    export PATH="/Users/Shared/flutter/bin:$PATH"
    export PATH="/usr/bin/ruby:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/bin/pod:$PATH"
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    echo "PATH: $PATH"

    echo "Pod version:"
    pod --version

    # Check Ruby and Flutter installations
    if ! ruby -v > /dev/null 2>&1; then
      echo "Error: Ruby is not installed or not in PATH"
      exit 1
    fi

    if ! which flutter > /dev/null 2>&1; then
      echo "Error: Flutter is not installed or not in PATH"
      exit 1
    fi

    flutter --version

    echo "Step 2: Getting packages"
    flutter pub get

    echo "Step 3: Building"

    cd ios || { echo "Error: ios directory not found"; exit 1; }

    echo "Current directory: $PWD"

    # Check if CocoaPods repo exists
    if [ ! -d "$HOME/.cocoapods/repos/MTXAnalyst" ]; then
      echo "Adding MTXAnalyst repo..."
      pod repo add MTXAnalyst https://kamil.ozturk%40optimusyazilim.com.tr:OptMat12935x!@gitlab.matriksdata.com/ios/mtx-pods.git
    else
      echo "MTXAnalyst repo already exists."
    fi

    # Install pods
    echo "Running pod install..."
    pod install || { echo "Pod install failed"; exit 1; }

    cd ..

    # Build the iOS IPA
    if ! flutter build ipa --release; then
      echo "Error: Flutter build failed"
      exit 1
    fi

    # Check if IPA file was generated
    if [ ! -f "$IPA_PATH" ]; then
      echo "Error: IPA file not found at $IPA_PATH"
      exit 1
    fi
fi

# Move and rename the IPA file
DEST_IPA="${DATENOWTIMESTAMP}_${COMPANY_NAME}_${PACKAGE_VERSION}.ipa"
cp "$IPA_PATH" "./$DEST_IPA" || { echo "Error: Failed to move IPA file"; exit 1; }

# Archive a copy
cp "$IPA_PATH" "$ARCHIVES_DIR/${DEST_IPA}" || { echo "Error: Failed to archive IPA file"; exit 1; }

echo "IPA file moved: ${PACKAGE_NAME}.ipa -> ${DEST_IPA}"
echo "IPA file archived in: $ARCHIVES_DIR/${DEST_IPA}"

echo "IPA dosyanızı Apple'a yüklemek için iki seçeneğiniz var:"
echo "1. Transporter uygulamasını kullanarak: https://apps.apple.com/us/app/transporter/id1450874784"
echo "   - IPA dosyasını ($DEST_IPA) Transporter uygulamasına sürükleyip bırakabilirsiniz"
echo "2. Terminal üzerinden altool kullanarak yükleme yapabilirsiniz."

echo -n "Hangi yöntemi kullanmak istersiniz? (1/2): "
read UPLOAD_METHOD

if [ "$UPLOAD_METHOD" = "2" ]; then
    # First, validate the IPA
    echo "Validating IPA file..."
    if ! xcrun altool --validate-app \
      -f "$DEST_IPA" \
      -t ios \
      -u "$APPLE_ID" \
      -p "$PASSWORD_ARG"; then
      echo "Error: IPA validation failed"
      exit 1
    fi

    # Upload to TestFlight
    echo "Uploading IPA to TestFlight..."
    if ! xcrun altool --upload-app \
      -f "$DEST_IPA" \
      -t ios \
      -u "$APPLE_ID" \
      -p "$PASSWORD_ARG"; then
      echo "Error: TestFlight upload failed"
      exit 1
    fi

    echo "Successfully uploaded to TestFlight!"
else
    echo "Lütfen $DEST_IPA dosyasını Transporter uygulamasına sürükleyip bırakın."
    echo "Transporter uygulamasını Mac App Store'dan indirmediyseniz, şu adresten indirebilirsiniz:"
    echo "https://apps.apple.com/us/app/transporter/id1450874784"
fi

# Cleanup - only remove working copy, keep archive
echo "Cleaning up working directory..."
rm -f "$DEST_IPA"

echo "Your IPA file is archived in: $ARCHIVES_DIR/${DEST_IPA}"

exit 0