# CS310 Serverpod backend

This folder is the Postgres-backed email authentication backend for the Flutter app.

## Included

- PostgreSQL config for local development
- Serverpod package setup
- Secret template for JWT and SMTP
- Docker Compose for the database

## Finish setup locally

1. Install the CLI:

```bash
dart pub global activate serverpod_cli
```

2. Copy the secrets file:

```bash
cp config/passwords.yaml.example config/passwords.yaml
```

3. Fill in:

- `databasePassword`
- JWT secret values
- SMTP credentials

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

## Flutter run command

```bash
flutter run \
  --dart-define=SERVERPOD_SERVER_URL=http://localhost:8080/
```
