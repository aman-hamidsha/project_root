# cs310_app

Flutter client plus a Serverpod backend for the CS310 project.

## Linux desktop prerequisites

If you want to run the Flutter app on Linux, install the native desktop build
dependencies first. On Fedora, the key package for this project is
`libsecret-devel` because `flutter_secure_storage_linux` links against
`libsecret-1`.

Typical Fedora setup:

```bash
sudo dnf install clang cmake ninja-build pkgconf-pkg-config gtk3-devel libsecret-devel
```

If your system uses `g++` instead of `clang++`, this also works:

```bash
export CXX=g++
```

## Server setup

```bash
cd server
./bin/dev_setup.sh
./bin/dev_start.sh
```

If a previous server process is still running:

```bash
cd server
./bin/dev_stop.sh
./bin/dev_start.sh --restart
```

## Flutter run

```bash
flutter pub get
flutter run --dart-define=SERVERPOD_SERVER_URL=http://localhost:8080/
```
