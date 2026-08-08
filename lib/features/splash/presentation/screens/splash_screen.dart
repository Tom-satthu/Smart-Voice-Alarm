import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/debug/sva_startup_timing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/navigation/challenge_launch_coordinator.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/visual_widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _rise = Tween<double>(
      begin: 16,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndContinue();
    });
  }

  Future<void> _initializeAndContinue() async {
    SvaStartupTiming.mark('splash_init_begin');
    // Local entitlement only — billing refreshes after Home.
    await ref
        .read(trialEntitlementProvider.notifier)
        .initializeSuccessfulLaunch();
    SvaStartupTiming.mark('local_entitlement_ready');
    if (!mounted) return;
    final location = GoRouter.of(context).state.uri.toString();
    // Never overwrite an in-flight Math Challenge / ringing route.
    if (location.contains('/alarm/ringing/')) {
      debugPrint('[SVA-Challenge] splash skip home overwrite loc=$location');
      unawaited(
        ref
            .read(trialEntitlementProvider.notifier)
            .refreshBillingInBackground(),
      );
      return;
    }
    final pending = await ref
        .read(notificationServiceProvider)
        .peekIosPendingChallenge();
    if (!mounted) return;
    if (pending != null && pending.parentAlarmId.isNotEmpty) {
      ChallengeLaunchCoordinator.instance.enqueue(pending);
      debugPrint('[SVA-Challenge] splash → coordinator pending challenge');
      unawaited(
        ref
            .read(trialEntitlementProvider.notifier)
            .refreshBillingInBackground(),
      );
      return;
    }
    if (!mounted) return;
    SvaStartupTiming.mark('home_navigation');
    context.go(AppRoutes.home);
    unawaited(
      ref.read(trialEntitlementProvider.notifier).refreshBillingInBackground(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SvaStartupTiming.mark('home_first_frame');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                  offset: Offset(0, _rise.value),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandMark(size: 92, animated: true),
                    const SizedBox(height: AppConstants.spaceXl),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      l10n.appTagline,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space2xl),
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: context.colors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
