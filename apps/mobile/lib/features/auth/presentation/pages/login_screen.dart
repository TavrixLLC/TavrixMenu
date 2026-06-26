import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/waflo_button.dart';
import '../../../../shared/widgets/waflo_status_badge.dart';
import '../../../../shared/widgets/waflo_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

typedef ClerkSignInPanelBuilder =
    Widget Function(BuildContext context, AuthStatus authStatus);

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.config, super.key, this.clerkPanelBuilder});

  final AppConfig config;
  final ClerkSignInPanelBuilder? clerkPanelBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          final routeName = state.shouldOpenDashboard
              ? AppRouteNames.dashboard
              : AppRouteNames.businessSetup;
          Navigator.of(context).pushReplacementNamed(routeName);
        }
      },
      builder: (context, state) {
        return AppScaffold(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AuthHero(),
              const SizedBox(height: AppSpacing.lg),
              if (state.status == AuthStatus.failure &&
                  state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (config.missingQaConfigKeys.isNotEmpty)
                _AuthConfigurationNotice(config: config),
              if (config.hasClerkPublishableKey) ...[
                if (config.missingQaConfigKeys.isNotEmpty)
                  const SizedBox(height: AppSpacing.md),
                clerkPanelBuilder?.call(context, state.status) ??
                    _ClerkSignInPanel(config: config, authStatus: state.status),
              ],
              if (config.isDevAuthEnabled) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: state.status == AuthStatus.loading
                      ? 'Preparing'
                      : 'Continue in dev mode',
                  icon: Icons.login,
                  variant: AppButtonVariant.secondary,
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () => context.read<AuthCubit>().signInDevMode(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AuthConfigurationNotice extends StatelessWidget {
  const _AuthConfigurationNotice({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final missing = config.missingQaConfigKeys;
    final missingList = missing.join(', ');
    final isAuthBlocked = config.missingOperatorAuthConfigKeys.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kDebugMode
                ? 'Debug configuration missing'
                : 'Operator sign-in is not configured',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            kDebugMode
                ? 'Missing config keys: $missingList. Rebuild the QA APK with the documented --dart-define values.'
                : 'Contact Waflo support for the configured operator build.',
          ),
          if (kDebugMode && !isAuthBlocked) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Operator sign-in can continue, but QA should rebuild with all required keys.',
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WafloStatusBadge(
              label: 'Business workspace',
              icon: Icons.verified_outlined,
              color: AppColors.charcoalSoft,
              foregroundColor: AppColors.surfaceWhite,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Welcome to Waflo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.surfaceWhite,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Manage your business menu and loyalty workspace.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.surfaceWhite.withValues(alpha: 0.84),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClerkSignInPanel extends StatelessWidget {
  const _ClerkSignInPanel({required this.config, required this.authStatus});

  final AppConfig config;
  final AuthStatus authStatus;

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedOutBuilder: (context, authState) => OwnerAuthForm(
        config: config,
        authClient: ClerkOwnerAuthClient(authState),
      ),
      signedInBuilder: (context, authState) {
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<AuthCubit>().signInWithClerk();
            }
          });
        }

        if (authStatus == AuthStatus.failure) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'We still need to confirm which business workspace you can use.',
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Retry workspace check',
                  icon: Icons.refresh,
                  onPressed: () => context.read<AuthCubit>().signInWithClerk(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Sign out',
                  icon: Icons.logout,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          );
        }

        return const LoadingView(message: 'Checking your business access');
      },
    );
  }
}

abstract class OwnerAuthClient {
  const OwnerAuthClient();

  bool get isSignedIn;

  Future<void> requestSignInCode({
    required clerk.Strategy strategy,
    required String identifier,
  });

  Future<OwnerAuthCompletion> verifySignInCode({
    required clerk.Strategy strategy,
    required String code,
  });

  Future<void> requestOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String identifier,
  });

  Future<OwnerAuthCompletion> verifyOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String code,
  });
}

class OwnerAuthCompletion {
  const OwnerAuthCompletion._({required this.isComplete, this.requiredStep});

  const OwnerAuthCompletion.complete() : this._(isComplete: true);

  const OwnerAuthCompletion.incomplete(String requiredStep)
    : this._(isComplete: false, requiredStep: requiredStep);

  final bool isComplete;
  final String? requiredStep;
}

class ClerkOwnerAuthClient implements OwnerAuthClient {
  const ClerkOwnerAuthClient(this._authState);

  final ClerkAuthState _authState;

  @override
  bool get isSignedIn => _authState.isSignedIn;

  @override
  Future<void> requestSignInCode({
    required clerk.Strategy strategy,
    required String identifier,
  }) {
    return _authState.attemptSignIn(strategy: strategy, identifier: identifier);
  }

  @override
  Future<OwnerAuthCompletion> verifySignInCode({
    required clerk.Strategy strategy,
    required String code,
  }) async {
    await _authState.attemptSignIn(strategy: strategy, code: code);
    return _completionFromAuthState(_authState);
  }

  @override
  Future<void> requestOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String identifier,
  }) {
    return _authState.attemptSignUp(
      strategy: strategy,
      emailAddress: strategy == clerk.Strategy.emailCode ? identifier : null,
      phoneNumber: strategy == clerk.Strategy.phoneCode ? identifier : null,
      legalAccepted: true,
    );
  }

  @override
  Future<OwnerAuthCompletion> verifyOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String code,
  }) async {
    final client = await _authState.attemptSignUp(
      strategy: strategy,
      code: code,
    );
    await _activateCreatedSessionIfNeeded(client);
    return _completionFromAuthState(_authState);
  }

  Future<void> _activateCreatedSessionIfNeeded(clerk.Client client) async {
    if (_authState.isSignedIn) {
      return;
    }

    final createdSessionId =
        client.signUp?.createdSessionId ??
        _authState.signUp?.createdSessionId ??
        client.signIn?.createdSessionId ??
        _authState.signIn?.createdSessionId;
    if (createdSessionId == null || createdSessionId.trim().isEmpty) {
      await _authState.refreshClient();
      return;
    }

    final session =
        _sessionById(client, createdSessionId) ??
        _sessionById(_authState.client, createdSessionId);
    if (session != null) {
      await _authState.activate(session);
      return;
    }

    await _authState.refreshClient();
    final refreshedSession = _sessionById(_authState.client, createdSessionId);
    if (refreshedSession != null && !_authState.isSignedIn) {
      await _authState.activate(refreshedSession);
    }
  }
}

clerk.Session? _sessionById(clerk.Client client, String sessionId) {
  for (final session in client.sessions) {
    if (session.id == sessionId) {
      return session;
    }
  }
  return null;
}

OwnerAuthCompletion _completionFromAuthState(ClerkAuthState authState) {
  if (authState.isSignedIn) {
    return const OwnerAuthCompletion.complete();
  }

  final signUp = authState.signUp;
  if (signUp != null) {
    return OwnerAuthCompletion.incomplete(_pendingSignUpStep(signUp));
  }

  final signIn = authState.signIn;
  if (signIn != null) {
    return OwnerAuthCompletion.incomplete(_pendingSignInStep(signIn));
  }

  return const OwnerAuthCompletion.incomplete(
    'Complete the required verification step',
  );
}

String _pendingSignUpStep(clerk.SignUp signUp) {
  final unverified = signUp.unverifiedFields;
  if (unverified.contains(clerk.Field.emailAddress)) {
    return 'Verify work email';
  }
  if (unverified.contains(clerk.Field.phoneNumber)) {
    return 'Verify work phone';
  }

  final missing = signUp.missingFields;
  if (missing.contains(clerk.Field.emailAddress)) {
    return 'Add work email';
  }
  if (missing.contains(clerk.Field.phoneNumber)) {
    return 'Add work phone';
  }
  if (missing.contains(clerk.Field.firstName) ||
      missing.contains(clerk.Field.lastName)) {
    return 'Complete business owner name';
  }
  if (missing.contains(clerk.Field.password)) {
    return 'Add account password';
  }
  if (missing.contains(clerk.Field.legalAccepted)) {
    return 'Accept required terms';
  }
  if (missing.contains(clerk.Field.enterpriseSSO) ||
      missing.contains(clerk.Field.saml)) {
    return 'Complete enterprise sign-in';
  }
  if (missing.contains(clerk.Field.externalAccount)) {
    return 'Complete external account verification';
  }

  return 'Complete the required verification step';
}

String _pendingSignInStep(clerk.SignIn signIn) {
  final verification = signIn.verification;
  final strategy = verification?.strategy;
  if (strategy == clerk.Strategy.emailCode ||
      strategy == clerk.Strategy.emailLink) {
    return 'Verify work email';
  }
  if (strategy == clerk.Strategy.phoneCode) {
    return 'Verify work phone';
  }
  if (strategy?.isPassword == true) {
    return 'Enter account password';
  }
  if (strategy?.isSSO == true) {
    return 'Complete external sign-in';
  }
  if (signIn.needsSecondFactor) {
    return 'Complete second verification factor';
  }
  return 'Complete the required verification step';
}

enum _AuthFlow { signIn, ownerSignUp }

enum _AuthStep { choice, identifier, code }

class OwnerAuthForm extends StatefulWidget {
  const OwnerAuthForm({
    required this.config,
    required this.authClient,
    super.key,
  });

  final AppConfig config;
  final OwnerAuthClient authClient;

  @override
  State<OwnerAuthForm> createState() => _OwnerAuthFormState();
}

class _OwnerAuthFormState extends State<OwnerAuthForm> {
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  _AuthFlow? _flow;
  _AuthStep _step = _AuthStep.choice;
  clerk.Strategy? _otpStrategy;
  bool _isBusy = false;
  _AuthNotice? _localMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = _flow;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_step == _AuthStep.choice)
            _AuthChoiceStep(onSelect: _startFlow)
          else ...[
            _FlowHeader(flow: flow!, onBack: _resetToChoice),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_step == _AuthStep.identifier && flow != null)
            _IdentifierStep(
              controller: _identifierController,
              isBusy: _isBusy,
              flow: flow,
              onSubmit: _sendCode,
            )
          else if (_step == _AuthStep.code && flow != null)
            _CodeStep(
              controller: _codeController,
              isBusy: _isBusy,
              flow: flow,
              onSubmit: _verifyCode,
              onChangeIdentifier: _resetIdentifier,
              onResend: _sendCode,
            ),
          if (_localMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AuthNoticeCard(notice: _localMessage!),
          ],
          const SizedBox(height: AppSpacing.lg),
          const _TrustLinks(),
        ],
      ),
    );
  }

  Future<void> _sendCode() async {
    final flow = _flow;
    if (flow == null) {
      setState(() => _localMessage = _AuthNotice.chooseAuthPath);
      return;
    }

    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _localMessage = _AuthNotice.missingIdentifier);
      return;
    }

    final strategy = identifier.contains('@')
        ? clerk.Strategy.emailCode
        : clerk.Strategy.phoneCode;
    setState(() {
      _isBusy = true;
      _localMessage = null;
      _otpStrategy = strategy;
    });

    try {
      if (flow == _AuthFlow.ownerSignUp) {
        await widget.authClient.requestOwnerSignUpCode(
          strategy: strategy,
          identifier: identifier,
        );
      } else {
        await widget.authClient.requestSignInCode(
          strategy: strategy,
          identifier: identifier,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _step = _AuthStep.code;
        _isBusy = false;
        _codeController.clear();
      });
    } on clerk.ClerkError catch (error) {
      _setAuthError(
        _authErrorNotice(error, flow: flow, stage: _AuthStage.start),
      );
    } on Object {
      _setAuthError(
        flow == _AuthFlow.ownerSignUp
            ? _AuthNotice.signUpStartFailed
            : _AuthNotice.signInStartFailed,
      );
    }
  }

  Future<void> _verifyCode() async {
    final flow = _flow;
    final strategy = _otpStrategy;
    final code = _codeController.text.trim();
    if (flow == null) {
      setState(() => _localMessage = _AuthNotice.chooseAuthPath);
      return;
    }
    if (strategy == null) {
      setState(() => _localMessage = _AuthNotice.startAgain);
      return;
    }
    if (code.length < 4) {
      setState(() => _localMessage = _AuthNotice.missingCode);
      return;
    }

    setState(() {
      _isBusy = true;
      _localMessage = null;
    });

    try {
      if (flow == _AuthFlow.ownerSignUp) {
        final completion = await widget.authClient.verifyOwnerSignUpCode(
          strategy: strategy,
          code: code,
        );
        if (!mounted) {
          return;
        }
        if (completion.isComplete && widget.authClient.isSignedIn) {
          context.read<AuthCubit>().signInWithClerk();
        } else {
          _setAuthError(
            _AuthNotice.needsMoreVerification(completion.requiredStep),
          );
        }
      } else {
        final completion = await widget.authClient.verifySignInCode(
          strategy: strategy,
          code: code,
        );
        if (!mounted) {
          return;
        }
        if (completion.isComplete && widget.authClient.isSignedIn) {
          context.read<AuthCubit>().signInWithClerk();
        } else {
          _setAuthError(
            _AuthNotice.needsMoreVerification(completion.requiredStep),
          );
        }
      }
    } on clerk.ClerkError catch (error) {
      _setAuthError(
        _authErrorNotice(error, flow: flow, stage: _AuthStage.verify),
      );
    } on Object {
      _setAuthError(_AuthNotice.verifyFailed);
    }
  }

  void _startFlow(_AuthFlow flow) {
    setState(() {
      _flow = flow;
      _step = _AuthStep.identifier;
      _otpStrategy = null;
      _codeController.clear();
      _localMessage = null;
      _isBusy = false;
    });
  }

  void _resetToChoice() {
    setState(() {
      _flow = null;
      _step = _AuthStep.choice;
      _otpStrategy = null;
      _identifierController.clear();
      _codeController.clear();
      _localMessage = null;
      _isBusy = false;
    });
  }

  void _resetIdentifier() {
    setState(() {
      _step = _AuthStep.identifier;
      _otpStrategy = null;
      _codeController.clear();
      _localMessage = null;
      _isBusy = false;
    });
  }

  void _setAuthError(_AuthNotice message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
      _localMessage = message;
    });
  }
}

enum _AuthStage { start, verify }

class _AuthNotice {
  const _AuthNotice({required this.title, required this.body, this.detail});

  final String title;
  final String body;
  final String? detail;

  static const chooseAuthPath = _AuthNotice(
    title: 'Choose how to continue',
    body: 'Choose sign in or create business workspace to continue.',
  );

  static const missingIdentifier = _AuthNotice(
    title: 'Enter account contact',
    body: 'Enter your work email or phone number.',
  );

  static const missingCode = _AuthNotice(
    title: 'Enter verification code',
    body: 'Enter the verification code from your email or phone.',
  );

  static const startAgain = _AuthNotice(
    title: 'Start again',
    body: 'Request a fresh code before continuing.',
  );

  static const accountNotFound = _AuthNotice(
    title: 'Account not found',
    body:
        "We couldn't find an existing Waflo business account for this email or phone. To start a new business, choose Create business workspace.",
  );

  static const signInStartFailed = _AuthNotice(
    title: 'Something went wrong',
    body: "We couldn't complete this action right now. Please try again.",
  );

  static const signUpStartFailed = _AuthNotice(
    title: 'Something went wrong',
    body: "We couldn't complete this action right now. Please try again.",
  );

  static const verifyFailed = _AuthNotice(
    title: 'Something went wrong',
    body: "We couldn't complete this action right now. Please try again.",
  );

  static _AuthNotice needsMoreVerification(String? requiredStep) => _AuthNotice(
    title: 'More verification needed',
    body: 'Complete the required verification step to continue.',
    detail: requiredStep == null || requiredStep.trim().isEmpty
        ? null
        : 'Required step: ${requiredStep.trim()}.',
  );

  static const tooManyAttempts = _AuthNotice(
    title: 'Try again soon',
    body:
        'Too many attempts were made. Wait a moment, then request a new code.',
  );
}

_AuthNotice _authErrorNotice(
  clerk.ClerkError error, {
  required _AuthFlow flow,
  required _AuthStage stage,
}) {
  if (error.code == clerk.ClerkErrorCode.tooManyRetries) {
    return _AuthNotice.tooManyAttempts;
  }

  final searchable = [
    error.message,
    error.argument ?? '',
    error.code.name,
  ].join(' ').toLowerCase();

  if (flow == _AuthFlow.signIn &&
      stage == _AuthStage.start &&
      _looksLikeUnknownAccount(searchable)) {
    return _AuthNotice.accountNotFound;
  }

  if (flow == _AuthFlow.ownerSignUp && stage == _AuthStage.start) {
    return _AuthNotice.signUpStartFailed;
  }

  return stage == _AuthStage.verify
      ? _AuthNotice.verifyFailed
      : _AuthNotice.signInStartFailed;
}

bool _looksLikeUnknownAccount(String message) {
  return message.contains('find your account') ||
      message.contains('account not found') ||
      message.contains('not found') ||
      message.contains('no account');
}

class _AuthNoticeCard extends StatelessWidget {
  const _AuthNoticeCard({required this.notice});

  final _AuthNotice notice;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerRed),
          const SizedBox(height: AppSpacing.sm),
          Text(notice.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(notice.body),
          if (notice.detail != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(notice.detail!),
          ],
        ],
      ),
    );
  }
}

class _AuthChoiceStep extends StatelessWidget {
  const _AuthChoiceStep({required this.onSelect});

  final ValueChanged<_AuthFlow> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your workspace path',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Use an existing Waflo business account or create a new workspace.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        WafloButton(
          label: 'Sign in to existing workspace',
          icon: Icons.login,
          onPressed: () => onSelect(_AuthFlow.signIn),
        ),
        const SizedBox(height: AppSpacing.sm),
        WafloButton(
          label: 'Create business workspace',
          icon: Icons.storefront_outlined,
          onPressed: () => onSelect(_AuthFlow.ownerSignUp),
          variant: WafloButtonVariant.secondary,
        ),
      ],
    );
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({required this.flow, required this.onBack});

  final _AuthFlow flow;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isSignIn = flow == _AuthFlow.signIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isSignIn
              ? 'Sign in to your workspace'
              : 'Create your Waflo business workspace',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isSignIn
              ? 'Enter the work email or phone on your Waflo account.'
              : 'Start a new business owner workspace with your work email or phone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _IdentifierStep extends StatelessWidget {
  const _IdentifierStep({
    required this.controller,
    required this.isBusy,
    required this.flow,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isBusy;
  final _AuthFlow flow;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WafloTextField(
          label: 'Work email or phone',
          hint: 'owner@example.com',
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          prefixIcon: Icons.alternate_email,
          onSubmitted: (_) {
            if (!isBusy) {
              onSubmit();
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        WafloButton(
          label: isBusy ? 'Sending code' : 'Continue',
          icon: Icons.arrow_forward,
          isLoading: isBusy,
          onPressed: isBusy ? null : onSubmit,
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.controller,
    required this.isBusy,
    required this.flow,
    required this.onSubmit,
    required this.onChangeIdentifier,
    required this.onResend,
  });

  final TextEditingController controller;
  final bool isBusy;
  final _AuthFlow flow;
  final VoidCallback onSubmit;
  final VoidCallback onChangeIdentifier;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WafloTextField(
          label: 'Verification code',
          hint: '123456',
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          prefixIcon: Icons.pin_outlined,
          onSubmitted: (_) {
            if (!isBusy) {
              onSubmit();
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        WafloButton(
          label: isBusy
              ? 'Verifying'
              : flow == _AuthFlow.ownerSignUp
              ? 'Verify and create workspace'
              : 'Verify and sign in',
          icon: Icons.verified_outlined,
          isLoading: isBusy,
          onPressed: isBusy ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: WafloButton(
                label: 'Resend code',
                icon: Icons.refresh,
                onPressed: isBusy ? null : onResend,
                variant: WafloButtonVariant.ghost,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: WafloButton(
                label: 'Change login',
                icon: Icons.edit_outlined,
                onPressed: isBusy ? null : onChangeIdentifier,
                variant: WafloButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrustLinks extends StatelessWidget {
  const _TrustLinks();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'By continuing, you agree to Waflo ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _PolicyLink(label: 'Terms', uri: Uri.https('waflo.app', '/terms')),
        Text(' and ', style: Theme.of(context).textTheme.bodyMedium),
        _PolicyLink(label: 'Privacy', uri: Uri.https('waflo.app', '/privacy')),
        Text('.', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink({required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(uri, mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryCoralDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
