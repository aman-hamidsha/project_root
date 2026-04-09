# Run Instructions (can work on DCS machines)

## 1. Install The Required Tools

You need these installed before the project will run:
- Flutter SDK
- Dart
- Chrome
- Android Studio if you want to run the Android app (optional)
- Docker or Podman with Compose support (optional)

to install dart:

```bash
cd ~
wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip dartsdk-linux-x64-release.zip
```

to add dart to path :

```bash
cd server
export PATH="$PATH:$HOME/dart-sdk/bin"
echo 'export PATH="$PATH:$HOME/dart-sdk/bin"' >> ~/.bashrc
source ~/.bashrc
```


to install flutter:

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

Check that Flutter is installed correctly:

```bash
flutter doctor
```


## 2. Run The Web App (recommended)

Open a new terminal in the project directory and run:

```bash
flutter pub get
flutter run -d chrome
```

This starts the Flutter web app in Chrome and points it at the local backend.




## 3. Start The Backend (optional, may have to install another version of flutter)
only needed to test leaderboard


From the project directory:


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

## 4. Run On An Android Emulator
If you want the Android version, open Android Studio and install:

- Android SDK
- Android SDK Platform-Tools
- Android Emulator
- at least one Android system image


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
