import 'dart:convert';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/copy/pilot_arabic_copy.dart';
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
        if (state.status == AuthStatus.restoring) {
          return const AppScaffold(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: LoadingView(message: PilotArabicCopy.restoringSession),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AppScaffold(
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
                      _ClerkSignInPanel(
                        config: config,
                        authStatus: state.status,
                      ),
                ],
                if (config.isDevAuthEnabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: state.status == AuthStatus.loading
                        ? PilotArabicCopy.checkingBusinessAccess
                        : PilotArabicCopy.testAccess,
                    icon: Icons.login,
                    variant: AppButtonVariant.secondary,
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () => context.read<AuthCubit>().signInDevMode(),
                  ),
                ],
              ],
            ),
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
    final isAuthBlocked = config.missingOperatorAuthConfigKeys.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PilotArabicCopy.appConfigNeedsAttention,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(PilotArabicCopy.operatorBuildSupport),
          if (!isAuthBlocked) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'تسجيل الدخول ممكن، لكن بعض الخدمات قد لا تعمل حتى تكتمل مراجعة نسخة التطبيق.',
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
              label: PilotArabicCopy.authBadge,
              icon: Icons.verified_outlined,
              color: AppColors.charcoalSoft,
              foregroundColor: AppColors.surfaceWhite,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              PilotArabicCopy.authTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.surfaceWhite,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              PilotArabicCopy.authSubtitle,
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
                  PilotArabicCopy.signedIn,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(PilotArabicCopy.confirmBusinessAccess),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: PilotArabicCopy.retryWorkspaceCheck,
                  icon: Icons.refresh,
                  onPressed: () => context.read<AuthCubit>().signInWithClerk(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: PilotArabicCopy.signOut,
                  icon: Icons.logout,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          );
        }

        return const LoadingView(
          message: PilotArabicCopy.checkingBusinessAccess,
        );
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
  const OwnerAuthCompletion._({
    required this.isComplete,
    this.requiredStep,
    this.requiresPassword = false,
  });

  const OwnerAuthCompletion.complete() : this._(isComplete: true);

  const OwnerAuthCompletion.incomplete(String requiredStep)
    : this._(isComplete: false, requiredStep: requiredStep);

  const OwnerAuthCompletion.passwordRequired()
    : this._(
        isComplete: false,
        requiredStep: PilotArabicCopy.passwordRequiredStep,
        requiresPassword: true,
      );

  final bool isComplete;
  final String? requiredStep;
  final bool requiresPassword;
}

class ClerkOwnerAuthClient implements OwnerAuthClient {
  const ClerkOwnerAuthClient(this._authState);

  static const _clerkPersistedClientKey = r'$client';

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
    await _persistActiveClerkClientIfSignedIn();
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
    await _persistActiveClerkClientIfSignedIn();
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

  Future<void> _persistActiveClerkClientIfSignedIn() async {
    if (!_authState.isSignedIn || _authState.client.user == null) {
      return;
    }

    await _authState.config.persistor.write<String>(
      _clerkPersistedClientKey,
      jsonEncode(_authState.client),
    );
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
    return _completionFromSignUp(signUp);
  }

  final signIn = authState.signIn;
  if (signIn != null) {
    return OwnerAuthCompletion.incomplete(_pendingSignInStep(signIn));
  }

  return const OwnerAuthCompletion.incomplete('أكمل خطوة التحقق المطلوبة');
}

OwnerAuthCompletion _completionFromSignUp(clerk.SignUp signUp) {
  final unverified = signUp.unverifiedFields;
  if (unverified.contains(clerk.Field.emailAddress)) {
    return const OwnerAuthCompletion.incomplete('تحقق من إيميل العمل');
  }
  if (unverified.contains(clerk.Field.phoneNumber)) {
    return const OwnerAuthCompletion.incomplete('تحقق من رقم الهاتف');
  }

  final missing = signUp.missingFields;
  if (missing.contains(clerk.Field.emailAddress)) {
    return const OwnerAuthCompletion.incomplete('أضف إيميل العمل');
  }
  if (missing.contains(clerk.Field.phoneNumber)) {
    return const OwnerAuthCompletion.incomplete('أضف رقم الهاتف');
  }
  if (missing.contains(clerk.Field.firstName) ||
      missing.contains(clerk.Field.lastName)) {
    return const OwnerAuthCompletion.incomplete('أكمل اسم صاحب المطعم');
  }
  if (signUp.status == clerk.Status.missingRequirements &&
      missing.contains(clerk.Field.password)) {
    return const OwnerAuthCompletion.passwordRequired();
  }
  if (missing.contains(clerk.Field.legalAccepted)) {
    return const OwnerAuthCompletion.incomplete('اقبل الشروط المطلوبة');
  }
  if (missing.contains(clerk.Field.enterpriseSSO) ||
      missing.contains(clerk.Field.saml)) {
    return const OwnerAuthCompletion.incomplete('أكمل تسجيل الدخول المطلوب');
  }
  if (missing.contains(clerk.Field.externalAccount)) {
    return const OwnerAuthCompletion.incomplete('أكمل تحقق الحساب الخارجي');
  }

  return const OwnerAuthCompletion.incomplete('أكمل خطوة التحقق المطلوبة');
}

String _pendingSignInStep(clerk.SignIn signIn) {
  final verification = signIn.verification;
  final strategy = verification?.strategy;
  if (strategy == clerk.Strategy.emailCode ||
      strategy == clerk.Strategy.emailLink) {
    return 'تحقق من إيميل العمل';
  }
  if (strategy == clerk.Strategy.phoneCode) {
    return 'تحقق من رقم الهاتف';
  }
  if (strategy?.isPassword == true) {
    return 'أدخل كلمة مرور الحساب';
  }
  if (strategy?.isSSO == true) {
    return 'أكمل تسجيل الدخول الخارجي';
  }
  if (signIn.needsSecondFactor) {
    return 'أكمل خطوة التحقق الثانية';
  }
  return 'أكمل خطوة التحقق المطلوبة';
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
            completion.requiresPassword
                ? _AuthNotice.passwordlessSignupConfigNeeded
                : _AuthNotice.needsMoreVerification(completion.requiredStep),
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
    title: 'اختر طريقة البدء',
    body: 'اختر دخول لمساحة موجودة أو إنشاء مساحة مطعم جديدة.',
  );

  static const missingIdentifier = _AuthNotice(
    title: 'أدخل وسيلة الدخول',
    body: 'اكتب إيميل العمل أو رقم الهاتف.',
  );

  static const missingCode = _AuthNotice(
    title: 'أدخل رمز التحقق',
    body: 'اكتب الرمز الذي وصلك على الإيميل أو الهاتف.',
  );

  static const startAgain = _AuthNotice(
    title: 'ابدأ من جديد',
    body: 'اطلب رمز جديد قبل الاستمرار.',
  );

  static const accountNotFound = _AuthNotice(
    title: PilotArabicCopy.accountNotFoundTitle,
    body: PilotArabicCopy.accountNotFoundBody,
  );

  static const signInStartFailed = _AuthNotice(
    title: PilotArabicCopy.authTemporaryErrorTitle,
    body: PilotArabicCopy.authTemporaryErrorBody,
  );

  static const signUpStartFailed = _AuthNotice(
    title: PilotArabicCopy.authTemporaryErrorTitle,
    body: PilotArabicCopy.authTemporaryErrorBody,
  );

  static const verifyFailed = _AuthNotice(
    title: PilotArabicCopy.verificationFailedTitle,
    body: PilotArabicCopy.verificationFailedBody,
  );

  static _AuthNotice needsMoreVerification(String? requiredStep) => _AuthNotice(
    title: PilotArabicCopy.needsMoreVerificationTitle,
    body: PilotArabicCopy.needsMoreVerificationBody,
    detail: requiredStep == null || requiredStep.trim().isEmpty
        ? null
        : requiredStep.trim(),
  );

  static const passwordlessSignupConfigNeeded = _AuthNotice(
    title: PilotArabicCopy.passwordlessSetupTitle,
    body: PilotArabicCopy.passwordlessSetupBody,
  );

  static const tooManyAttempts = _AuthNotice(
    title: PilotArabicCopy.tooManyAttemptsTitle,
    body: PilotArabicCopy.tooManyAttemptsBody,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PilotArabicCopy.authChoiceTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            PilotArabicCopy.authChoiceSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          WafloButton(
            label: PilotArabicCopy.signInExistingWorkspace,
            icon: Icons.login,
            onPressed: () => onSelect(_AuthFlow.signIn),
          ),
          const SizedBox(height: AppSpacing.sm),
          WafloButton(
            label: PilotArabicCopy.createBusinessWorkspace,
            icon: Icons.storefront_outlined,
            onPressed: () => onSelect(_AuthFlow.ownerSignUp),
            variant: WafloButtonVariant.secondary,
          ),
        ],
      ),
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
              ? PilotArabicCopy.signInHeader
              : PilotArabicCopy.signUpHeader,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isSignIn
              ? PilotArabicCopy.signInSubtitle
              : PilotArabicCopy.signUpSubtitle,
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
          label: PilotArabicCopy.contactLabel,
          hint: PilotArabicCopy.contactHint,
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
          label: isBusy
              ? PilotArabicCopy.sendingCode
              : PilotArabicCopy.continueLabel,
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
          label: PilotArabicCopy.verificationCode,
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
              ? PilotArabicCopy.verifying
              : flow == _AuthFlow.ownerSignUp
              ? PilotArabicCopy.verifyAndCreate
              : PilotArabicCopy.verifyAndSignIn,
          icon: Icons.verified_outlined,
          isLoading: isBusy,
          onPressed: isBusy ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: WafloButton(
                label: PilotArabicCopy.resendCode,
                icon: Icons.refresh,
                onPressed: isBusy ? null : onResend,
                variant: WafloButtonVariant.ghost,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: WafloButton(
                label: PilotArabicCopy.changeLogin,
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
          'بالمتابعة أنت توافق على ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        _PolicyLink(label: 'الشروط', uri: Uri.https('waflo.app', '/terms')),
        Text(' و ', style: Theme.of(context).textTheme.bodyMedium),
        _PolicyLink(label: 'الخصوصية', uri: Uri.https('waflo.app', '/privacy')),
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
