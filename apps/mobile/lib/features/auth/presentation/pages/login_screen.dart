import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.config, super.key});

  final AppConfig config;

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
              const AppCard(
                child: Text(
                  'Customers browse public menus on the web. This app is for owners, managers, and staff who operate loyalty and menu workflows.',
                ),
              ),
              if (state.status == AuthStatus.failure &&
                  state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (config.hasClerkPublishableKey)
                _ClerkSignInPanel(config: config, authStatus: state.status)
              else
                const AppCard(
                  child: Text(
                    'Set CLERK_PUBLISHABLE_KEY to enable owner sign in and sign up.',
                  ),
                ),
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
              label: 'Business loyalty platform',
              icon: Icons.verified_outlined,
              color: AppColors.charcoalSoft,
              foregroundColor: AppColors.surfaceWhite,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Waflo Operator',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.surfaceWhite,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A focused workspace for restaurant and cafe teams to scan wallets, manage loyalty, and keep public menus accurate.',
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
      signedOutBuilder: (context, authState) =>
          _CustomClerkAuthForm(config: config, authState: authState),
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
                  'Clerk session found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'We still need to confirm your Waflo business access.',
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

enum _AuthStep { identifier, code }

class _CustomClerkAuthForm extends StatefulWidget {
  const _CustomClerkAuthForm({required this.config, required this.authState});

  final AppConfig config;
  final ClerkAuthState authState;

  @override
  State<_CustomClerkAuthForm> createState() => _CustomClerkAuthFormState();
}

class _CustomClerkAuthFormState extends State<_CustomClerkAuthForm> {
  static Future<void>? _googleInitializeFuture;
  static String? _googleInitializeKey;

  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  _AuthStep _step = _AuthStep.identifier;
  clerk.Strategy? _otpStrategy;
  bool _isBusy = false;
  bool _isGoogleBusy = false;
  String? _localMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in to Waflo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use the phone or email attached to your operator account.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_step == _AuthStep.identifier)
            _IdentifierStep(
              controller: _identifierController,
              isBusy: _isBusy,
              onSubmit: _sendCode,
            )
          else
            _CodeStep(
              controller: _codeController,
              isBusy: _isBusy,
              onSubmit: _verifyCode,
              onChangeIdentifier: _resetIdentifier,
              onResend: _sendCode,
            ),
          const SizedBox(height: AppSpacing.lg),
          _DividerLabel(label: 'or'),
          const SizedBox(height: AppSpacing.lg),
          _GoogleAuthButton(
            enabled: widget.config.hasGoogleNativeClientConfig,
            isLoading: _isGoogleBusy,
            onPressed: _signInWithGoogle,
          ),
          if (!widget.config.hasGoogleNativeClientConfig) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Native Google sign-in needs GOOGLE_CLIENT_ID or GOOGLE_SERVER_CLIENT_ID configured for this app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (_localMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            ErrorView(message: _localMessage!),
          ],
          const SizedBox(height: AppSpacing.lg),
          const _TrustLinks(),
        ],
      ),
    );
  }

  Future<void> _sendCode() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _localMessage = 'Enter your work email or phone number.');
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
      await widget.authState.attemptSignIn(
        strategy: strategy,
        identifier: identifier,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _step = _AuthStep.code;
        _isBusy = false;
      });
    } on clerk.ClerkError catch (error) {
      _setAuthError(error.toString());
    } on Object {
      _setAuthError(
        'We could not send a code. Check your account and try again.',
      );
    }
  }

  Future<void> _verifyCode() async {
    final strategy = _otpStrategy;
    final code = _codeController.text.trim();
    if (strategy == null) {
      setState(() => _localMessage = 'Start again to request a fresh code.');
      return;
    }
    if (code.length < 4) {
      setState(() => _localMessage = 'Enter the verification code.');
      return;
    }

    setState(() {
      _isBusy = true;
      _localMessage = null;
    });

    try {
      await widget.authState.attemptSignIn(strategy: strategy, code: code);
      if (!mounted) {
        return;
      }
      if (widget.authState.isSignedIn) {
        context.read<AuthCubit>().signInWithClerk();
      } else {
        _setAuthError('We need one more verification step for this account.');
      }
    } on clerk.ClerkError catch (error) {
      _setAuthError(error.toString());
    } on Object {
      _setAuthError('The code could not be verified. Try again.');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!widget.config.hasGoogleNativeClientConfig) {
      setState(
        () => _localMessage =
            'Native Google sign-in is not configured for this build.',
      );
      return;
    }

    setState(() {
      _isGoogleBusy = true;
      _localMessage = null;
    });

    try {
      await _initializeGoogleSignIn(widget.config);
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _setAuthError(
          'Native Google account picker is not available on this platform.',
        );
        return;
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _setAuthError('Google did not return an ID token for Clerk.');
        return;
      }

      await widget.authState.idTokenSignIn(
        provider: clerk.IdTokenProvider.google,
        idToken: idToken,
      );
      if (!mounted) {
        return;
      }
      if (widget.authState.isSignedIn) {
        context.read<AuthCubit>().signInWithClerk();
      } else {
        _setAuthError(
          'This Google account is not connected to a Waflo operator account.',
        );
      }
    } on GoogleSignInException catch (error) {
      _setAuthError(_googleMessage(error));
    } on clerk.ClerkError catch (error) {
      _setAuthError(error.toString());
    } on Object {
      _setAuthError('Google sign-in could not be completed.');
    }
  }

  Future<void> _initializeGoogleSignIn(AppConfig config) async {
    final key = [
      config.normalizedGoogleClientId ?? '',
      config.normalizedGoogleServerClientId ?? '',
    ].join('|');
    if (_googleInitializeFuture != null && _googleInitializeKey == key) {
      return _googleInitializeFuture;
    }
    _googleInitializeKey = key;
    _googleInitializeFuture = GoogleSignIn.instance.initialize(
      clientId: config.normalizedGoogleClientId,
      serverClientId: config.normalizedGoogleServerClientId,
    );
    return _googleInitializeFuture;
  }

  String _googleMessage(GoogleSignInException error) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Google sign-in was cancelled.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google account picker is unavailable on this device.',
      _ => 'Google sign-in is not ready for this build.',
    };
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

  void _setAuthError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
      _isGoogleBusy = false;
      _localMessage = message;
    });
  }
}

class _IdentifierStep extends StatelessWidget {
  const _IdentifierStep({
    required this.controller,
    required this.isBusy,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isBusy;
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
    required this.onSubmit,
    required this.onChangeIdentifier,
    required this.onResend,
  });

  final TextEditingController controller;
  final bool isBusy;
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
          label: isBusy ? 'Verifying' : 'Verify and enter',
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

class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WafloButton(
      label: isLoading ? 'Opening Google' : 'Continue with Google',
      icon: Icons.account_circle_outlined,
      isLoading: isLoading,
      onPressed: enabled && !isLoading ? onPressed : null,
      variant: WafloButtonVariant.secondary,
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const Expanded(child: Divider()),
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
