# Global variable to store device IP address
DEVICE_IP_ADDRESS := $(shell adb shell ip route | grep -oE 'src ([0-9]+\.){3}[0-9]+' | cut -d' ' -f2)
BRANCH_MAIN = main
BRANCH_DEV = dev

.PHONY: all web mobile run_unit clean upgrade lint format build apk help ios android connect_wireless disconnect_wireless config git logo_clean logo_trim

all: lint format run_dev_web

# Adding a help file: https://gist.github.com/prwhite/8168133#gistcomment-1313022
help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

run_unit: ## Runs unit tests
	@echo "╠ Running the tests"
	@flutter test || (echo "Error while running tests"; exit 1)

clean: format ## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@rm -rf ios/Podfile.lock
	@flutter clean
	@flutter pub get
	@flutter precache --ios
	@cd ios && pod deintegrate && pod install && cd ..
	
format: ## Formats the code
	@echo "╠ Formatting the code"
	@dart format .

web: ## Runs the web application in dev
	@echo "╠ Running the app"
	@flutter run -d chrome --dart-define=ENVIRONMENT=dev --web-renderer html

# mobile: format connect_wireless ## Runs the mobile application in dev
# 	@echo "╠ Running the app"
# 	@flutter run -d all -t lib/main.dart --dart-define=ENVIRONMENT=dev

# Android 
android: format ## Runs the mobile application in dev
	@echo "╠ Running the app"
	@flutter run -t lib/main.dart --dart-define=ENVIRONMENT=dev
# @flutter run -t lib/main.dart --enable-software-rendering --dart-define=ENVIRONMENT=dev

# iOS
ios: format ## Runs the mobile application in dev
	@echo "╠ Running the app"
	@flutter run -t lib/main.dart --dart-define=ENVIRONMENT=dev

lint: ## Lints the code
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "Error in project"; exit 1)

upgrade: clean ## Upgrades dependencies
	@echo "╠ Upgrading dependencies..."
	@flutter pub upgrade

build: ##clean ## Run Build Runner
	@echo "╠ Running Build Runner..."
	@dart run build_runner build --delete-conflicting-outputs

git: format
	@echo "╠ Committing changes..."
	@read -p "Enter commit message: " message; \
	git add .; \
	git commit -m "$$message"
	@echo "╠ Pushing changes to a remote repository..."
	@echo "Available branches:"
	@echo "1. $(BRANCH_MAIN)"
	@echo "2. $(BRANCH_DEV)"
	@read -p "Select branch to push [1/2]: " selection; \
	branch=`case "$$selection" in \
		1) echo "$(BRANCH_MAIN)" ;; \
		2) echo "$(BRANCH_DEV)" ;; \
		*) echo "$(BRANCH_MAIN)" ;; \
	esac`; \
	git push -u origin $$branch

connect_wireless: ## Connects to Android device wirelessly
	@echo "╠ Connecting to Android device wirelessly..."
	@adb start-server
	@adb devices
	@adb tcpip 5555
	@adb connect $(DEVICE_IP_ADDRESS):5555
	@echo "╠ Currently running flutter devices..."
	@flutter devices

disconnect_wireless: ## Disconnects from Android device wirelessly
	@echo "╠ Disconnecting from Android device wirelessly..."
	@adb disconnect $(DEVICE_IP_ADDRESS):5555

apk:  ## Builds the application
	@echo "╠  Building the app"
	@flutter build apk -t lib/main.dart --release

config:
	@echo "╠ Encoding app_config.json"
	@openssl base64 -in config/app_config.json -out config/app_config.txt

logo_clean: ## Remove near-grey background from assets/logo.png -> assets/logo_transparent.png (requires ImageMagick)
	@echo "╠ Cleaning logo background to transparent"
	@magick assets/logo.png -alpha on -fuzz 12% -transparent "#EDEDED" assets/logo_transparent.png || (echo "ImageMagick 'magick' not found. Install via 'brew install imagemagick'"; exit 1)

logo_trim: ## Trim transparent margins on assets/logo_transparent.png (requires ImageMagick)
	@echo "╠ Trimming transparent margins from logo_transparent.png"
	@magick assets/logo_transparent.png -trim +repage assets/logo_transparent.png || (echo "ImageMagick 'magick' not found. Install via 'brew install imagemagick'"; exit 1)


# --- Android Play release workflow ---

.PHONY: android-release-keystore android-signing-config android-build-release android-play-console

android-release-keystore: ## Generate release keystore at ~/Development/Keys if missing (will prompt for values)
	@if [ ! -f "$(HOME)/Development/Keys/jtc-release.keystore" ]; then \
		mkdir -p "$(HOME)/Development/Keys"; \
		echo "Generating release keystore..."; \
		keytool -genkey -v -keystore "$(HOME)/Development/Keys/jtc-release.keystore" \
			-alias jtc -keyalg RSA -keysize 2048 -validity 10000 \
			-storepass Funnet@2016## -keypass Funnet@2016## \
			-dname "CN=JTC Technology, OU=JTC, O=JTC Technology, L=Nairobi, ST=Nairobi, C=KE"; \
		if [ $$? -eq 0 ]; then echo 'Keystore created.'; else echo 'Keytool failed!'; exit 1; fi \
	else \
		echo 'Keystore already exists.'; \
	fi

android-signing-config: ## Copy example signing config if keystore.properties is missing (edit details after)
	@if [ ! -f keystore.properties ]; then \
		cp keystore.properties.example keystore.properties; \
		echo 'Edit keystore.properties to match your keystore location and password.'; \
	else \
		echo 'keystore.properties already exists.'; \
	fi

android-build-release: ## Build Play Store-ready signed App Bundle (.aab)
	make android-release-keystore
	make android-signing-config
	flutter clean
	flutter pub get
	flutter build appbundle --release

android-play-console: ## Open Google Play Console in browser
	@open https://play.google.com/console/u/0/developers


# --- iOS App Store release workflow ---

.PHONY: ios-pods ios-archive ios-export ios-organizer ios-build-ipa

ios-pods: ## Install CocoaPods for iOS
	cd ios && pod install

ios-archive: ios-pods ## Create Xcode archive for App Store
	rm -rf build/ios/Runner.xcarchive
	xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -sdk iphoneos \
		archive -archivePath build/ios/Runner.xcarchive \
		DEVELOPMENT_TEAM=82P5S67HJK PRODUCT_BUNDLE_IDENTIFIER=com.jtc.technologies \
		BUILD_LIBRARY_FOR_DISTRIBUTION=NO

ios-export: ## Export IPA from archive using ExportOptions.plist
	rm -rf build/ios/export
	xcodebuild -exportArchive -archivePath build/ios/Runner.xcarchive \
		-exportOptionsPlist ios/ExportOptions.plist -exportPath build/ios/export

ios-organizer: ## Open Xcode Organizer on the archive
	open -a Xcode build/ios/Runner.xcarchive

ios-build-ipa: ## Build IPA via Flutter (simple path)
	flutter build ipa --release

serverpod: ## Run serverpod commands
	@echo "╠ Running serverpod command"
	@dart run bin/main.dart --apply-migrations	

