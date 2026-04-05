import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;

import 'endpoints/email_idp_endpoint.dart' as _i3;
import 'endpoints/scenario_endpoint.dart' as _i4;

/*
 * this file wires server endpoints into Serverpod's dispatch system.
 * it registers the scenario endpoint used by the app's training features and
 * the email auth identity-provider endpoint used for backend auth flows.
 */

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    // auth core is mounted as a module, while the app's custom scenario
    // endpoint is registered directly below.
    modules['serverpod_auth_core'] = _i2.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _EmailIdpModuleDispatch()
      ..initializeEndpoints(server);
    final endpoints = <String, _i1.Endpoint>{
      'scenario': _i4.ScenarioEndpoint()..initialize(server, 'scenario', null),
    };
    connectors['scenario'] = _i1.EndpointConnector(
      name: 'scenario',
      endpoint: endpoints['scenario']!,
      methodConnectors: {
        'getKeywordBriefing': _i1.MethodConnector(
          name: 'getKeywordBriefing',
          params: {
            'keyword': _i1.ParameterDescription(
              name: 'keyword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['scenario'] as _i4.ScenarioEndpoint)
                  .getKeywordBriefing(
            session,
            keyword: params['keyword'],
          ),
        ),
        'analyzeResponse': _i1.MethodConnector(
          name: 'analyzeResponse',
          params: {
            'simulator': _i1.ParameterDescription(
              name: 'simulator',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'scenarioId': _i1.ParameterDescription(
              name: 'scenarioId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'actionsSelected': _i1.ParameterDescription(
              name: 'actionsSelected',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'replyText': _i1.ParameterDescription(
              name: 'replyText',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'scenarioType': _i1.ParameterDescription(
              name: 'scenarioType',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['scenario'] as _i4.ScenarioEndpoint).analyzeResponse(
            session,
            simulator: params['simulator'],
            scenarioId: params['scenarioId'],
            actionsSelected: params['actionsSelected'],
            replyText: params['replyText'],
            scenarioType: params['scenarioType'],
          ),
        ),
        'getUserProgress': _i1.MethodConnector(
          name: 'getUserProgress',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['scenario'] as _i4.ScenarioEndpoint)
                  .getUserProgress(session),
        ),
        'listRecentResponses': _i1.MethodConnector(
          name: 'listRecentResponses',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['scenario'] as _i4.ScenarioEndpoint)
                  .listRecentResponses(
            session,
            limit: params['limit'],
          ),
        ),
      },
    );
  }
}

// separate dispatch wrapper for the email identity-provider module endpoints.
class _EmailIdpModuleDispatch extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    final endpoints = <String, _i1.Endpoint>{
      'email': _i3.EmailIdpEndpoint()
        ..initialize(server, 'email', 'serverpod_auth_idp'),
    };

    connectors['email'] = _i1.EndpointConnector(
      name: 'email',
      endpoint: endpoints['email']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint).login(
            session,
            email: params['email'],
            password: params['password'],
          ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint).startRegistration(
            session,
            email: params['email'],
          ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint)
                  .verifyRegistrationCode(
            session,
            accountRequestId: params['accountRequestId'],
            verificationCode: params['verificationCode'],
          ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint).finishRegistration(
            session,
            registrationToken: params['registrationToken'],
            password: params['password'],
          ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint).startPasswordReset(
            session,
            email: params['email'],
          ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
            session,
            passwordResetRequestId: params['passwordResetRequestId'],
            verificationCode: params['verificationCode'],
          ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['email'] as _i3.EmailIdpEndpoint).finishPasswordReset(
            session,
            finishPasswordResetToken: params['finishPasswordResetToken'],
            newPassword: params['newPassword'],
          ),
        ),
      },
    );
  }
}
