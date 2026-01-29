# Farm2Home Flutter App

A Flutter application for connecting farmers directly with consumers. This repository contains the Flutter client app and platform-specific projects for Android, iOS, web, and desktop.

## Features
- Farmer and customer onboarding
- Product discovery and listings
- Authentication and account management
- Cross‑platform support (Android, iOS, Web, Windows, macOS, Linux)

## Project Structure
- flutter_application_1/ — main Flutter app
- flutter_application_1/lib/ — Dart source code
- flutter_application_1/android/ — Android project
- flutter_application_1/ios/ — iOS project
- flutter_application_1/web/ — Web project
- flutter_application_1/windows/ — Windows desktop project
- flutter_application_1/macos/ — macOS desktop project
- flutter_application_1/linux/ — Linux desktop project

## Requirements
- Flutter SDK (latest stable recommended)
- Dart (bundled with Flutter)
- Android Studio/Xcode (for mobile builds)

## Getting Started
1) Install Flutter: https://docs.flutter.dev/get-started/install
2) Verify your setup:
	 - flutter doctor
3) Fetch dependencies:
	 - cd flutter_application_1
	 - flutter pub get

## Run the App
From the flutter_application_1 folder:

- Android/iOS (device or emulator):
	- flutter run

- Web:
	- flutter run -d chrome

- Windows/macOS/Linux:
	- flutter run -d windows
	- flutter run -d macos
	- flutter run -d linux

## Firebase
This project includes Firebase configuration files in the platform folders. If you create a new Firebase project, update the config files and regenerate `lib/firebase_options.dart` as needed.

## License
MIT