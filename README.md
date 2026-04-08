# CS310 Run Instructions

## 1. Install The Required Tools

You need these installed before the project will run:

- Flutter SDK
- Chrome
- Docker or Podman with Compose support
- Android Studio if you want to run the Android app

Check that Flutter is installed correctly:

```bash
flutter doctor
```

If you want the Android version, open Android Studio and install:

- Android SDK
- Android SDK Platform-Tools
- Android Emulator
- at least one Android system image

## 2. Start The Backend

From the project root:

```bash
cd server
./bin/dev_setup.sh
./bin/dev_start.sh
```

What this does:

- creates `server/config/passwords.yaml` from the example if it does not exist
- starts the bundled Postgres database
- applies migrations
- starts the Serverpod backend

If the server is already running and you want to restart it:

```bash
cd server
./bin/dev_stop.sh
./bin/dev_start.sh --restart
```

Leave this terminal open while the app is running.

## 3. Run The Web App

Open a new terminal in the project root and run:

```bash
flutter pub get
flutter run -d chrome 
```

This starts the Flutter web app in Chrome and points it at the local backend.

## 4. Run On An Android Emulator

First list the available emulators:

```bash
flutter emulators
```

Launch one:

```bash
flutter emulators --launch <emulator_id>
```

Confirm the device is available:

```bash
flutter devices
```

Then run the app on the emulator:

```bash
flutter pub get
flutter run -d <device_id> 
```


## 5. Run On Linux Desktop

Only do this if you want the desktop build instead of the web version.

On Fedora, install the native Linux dependencies first:

```bash
sudo dnf install clang cmake ninja-build pkgconf-pkg-config gtk3-devel libsecret-devel
```

Then run:

```bash
flutter pub get
flutter run -d linux --dart-define=SERVERPOD_SERVER_URL=http://localhost:8080/
```

If your system prefers `g++` over `clang++`, run this first:

```bash
export CXX=g++
```

## 6. Quick Start

If you just want the web app:

Terminal 1:

```bash
cd server
./bin/dev_setup.sh
./bin/dev_start.sh
```

Terminal 2:

```bash
cd ..
flutter pub get
flutter run -d chrome 
```
