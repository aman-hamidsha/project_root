import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth_core;
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

import 'src/endpoints.dart';
import 'src/generated/protocol.dart';

Future<void> run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      auth_core.JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  await pod.start();
}

Future<void> _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  await _sendEmail(
    session,
    recipient: email,
    subject: 'CS310 verification code',
    text:
        'Your CS310 verification code is $verificationCode. Request id: $accountRequestId',
  );
}

Future<void> _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  await _sendEmail(
    session,
    recipient: email,
    subject: 'CS310 password reset code',
    text:
        'Your CS310 password reset code is $verificationCode. Request id: $passwordResetRequestId',
  );
}

Future<void> _sendEmail(
  Session session, {
  required String recipient,
  required String subject,
  required String text,
}) async {
  final smtpServer = SmtpServer(
    session.passwords['smtpHost']!,
    port: int.parse(session.passwords['smtpPort']!),
    username: session.passwords['smtpUser']!,
    password: session.passwords['smtpPassword']!,
  );

  final message = mailer.Message()
    ..from = mailer.Address(
        session.passwords['smtpFromEmail']!, 'CS310 Security Trainer')
    ..recipients.add(recipient)
    ..subject = subject
    ..text = text;

  await mailer.send(message, smtpServer);
}
