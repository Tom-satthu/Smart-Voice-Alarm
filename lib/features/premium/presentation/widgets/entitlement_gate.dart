import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/trial_entitlement_service.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../screens/premium_screen.dart';

class EntitlementGate extends ConsumerStatefulWidget {
  const EntitlementGate({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  @override
  ConsumerState<EntitlementGate> createState() => _EntitlementGateState();
}

class _EntitlementGateState extends ConsumerState<EntitlementGate> {
  bool _restrictedAlarmAccess = false;

  @override
  void didUpdateWidget(covariant EntitlementGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPath.startsWith('/alarm/ringing/')) {
      _restrictedAlarmAccess = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlement = ref.watch(trialEntitlementProvider);
    final isRinging = widget.currentPath.startsWith('/alarm/ringing/');

    // Safety-critical alarm controls must never wait for Billing or be covered
    // by the paywall.
    if (isRinging ||
        widget.currentPath == AppRoutes.splash ||
        entitlement.status == EntitlementStatus.initializing ||
        entitlement.hasFullAccess) {
      return widget.child;
    }

    if (_restrictedAlarmAccess && widget.currentPath == AppRoutes.home) {
      return widget.child;
    }

    return PremiumScreen(
      mandatory: true,
      onViewExistingAlarms: () {
        context.go(AppRoutes.home);
        setState(() => _restrictedAlarmAccess = true);
      },
    );
  }
}
