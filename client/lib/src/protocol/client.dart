/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i2;
import 'package:serverpod_client/serverpod_client.dart' as _i3;
import 'protocol.dart' as _i4;

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i2.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i2.Caller serverpod_auth_core;
}

class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(super.caller);

  @override
  String get name => 'serverpod_auth_idp.email';

  @override
  Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
        'serverpod_auth_idp.email',
        'hasAccount',
        {},
      );

  @override
  Future<_i2.AuthSuccess> login({
    required String email,
    required String password,
  }) =>
      caller.callServerEndpoint<_i2.AuthSuccess>(
        'serverpod_auth_idp.email',
        'login',
        {
          'email': email,
          'password': password,
        },
      );

  @override
  Future<_i3.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i3.UuidValue>(
        'serverpod_auth_idp.email',
        'startRegistration',
        {
          'email': email,
        },
      );

  @override
  Future<String> verifyRegistrationCode({
    required _i3.UuidValue accountRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>(
        'serverpod_auth_idp.email',
        'verifyRegistrationCode',
        {
          'accountRequestId': accountRequestId,
          'verificationCode': verificationCode,
        },
      );

  @override
  Future<_i2.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) =>
      caller.callServerEndpoint<_i2.AuthSuccess>(
        'serverpod_auth_idp.email',
        'finishRegistration',
        {
          'registrationToken': registrationToken,
          'password': password,
        },
      );

  @override
  Future<_i3.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i3.UuidValue>(
        'serverpod_auth_idp.email',
        'startPasswordReset',
        {
          'email': email,
        },
      );

  @override
  Future<String> verifyPasswordResetCode({
    required _i3.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>(
        'serverpod_auth_idp.email',
        'verifyPasswordResetCode',
        {
          'passwordResetRequestId': passwordResetRequestId,
          'verificationCode': verificationCode,
        },
      );

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) =>
      caller.callServerEndpoint<void>(
        'serverpod_auth_idp.email',
        'finishPasswordReset',
        {
          'finishPasswordResetToken': finishPasswordResetToken,
          'newPassword': newPassword,
        },
      );
}

class Client extends _i3.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i3.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i3.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i4.Protocol(),
          securityContext: securityContext,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    email = EndpointEmailIdp(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp email;

  late final Modules modules;

  @override
  Map<String, _i3.EndpointRef> get endpointRefLookup => {
        'serverpod_auth_idp.email': email,
      };

  @override
  Map<String, _i3.ModuleEndpointCaller> get moduleLookup => {
        'serverpod_auth_idp': modules.serverpod_auth_idp,
        'serverpod_auth_core': modules.serverpod_auth_core,
      };
}
