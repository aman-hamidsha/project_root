# CS310 Serverpod backend

This folder is the Postgres-backed email authentication backend for the Flutter app.

## Included

- PostgreSQL config for local development
- Serverpod package setup
- Secret template for JWT and SMTP
- Docker Compose for the database

## Quick start

From an unzipped project, the cleanest setup flow is:

```bash
cd server
./bin/dev_setup.sh
./bin/dev_start.sh
```

`dev_setup.sh` will:

- create `config/passwords.yaml` from the example if it is missing
- start the bundled Postgres container
- apply the Serverpod migrations

## Manual setup

1. Install the CLI:

```bash
dart pub global activate serverpod_cli
```

2. Copy the secrets file:

```bash
cp config/passwords.yaml.example config/passwords.yaml
```

3. Fill in the `development:` section in `config/passwords.yaml`:

- `database`
- `serviceSecret`
- JWT secret values
- SMTP credentials

All values in `passwords.yaml` must be strings. For example, keep
`smtpPort` quoted as `'587'`.

If you want email sign-up/login to work, the SMTP values must be real.

4. Start Postgres:

```bash
docker compose up -d
```

5. Generate the actual Serverpod project files and auth tables:

```bash
serverpod generate
serverpod create-migration
dart run bin/main.dart --role maintenance --apply-migrations
dart run bin/main.dart
```

6. Generate the Flutter client package and wire it into the app.

The current Flutter code intentionally uses a placeholder factory in
`lib/src/core/backend/serverpod_client.dart`. Replace that file with an import
from the generated Serverpod `client` package once generation succeeds.

## Start commands

Server:

```bash
cd server
./bin/dev_start.sh
```

If a previous server process is still holding the ports, use:

```bash
cd server
./bin/dev_stop.sh
./bin/dev_start.sh --restart
```

Flutter app:

```bash
cd ..
flutter pub get
flutter run \
  --dart-define=SERVERPOD_SERVER_URL=http://localhost:8080/
```

## Flutter run command

```bash
flutter run \
  --dart-define=SERVERPOD_SERVER_URL=http://localhost:8080/
```
