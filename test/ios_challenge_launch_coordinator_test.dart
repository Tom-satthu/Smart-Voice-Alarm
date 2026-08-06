import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_voice_alarm/core/navigation/challenge_launch_coordinator.dart';
import 'package:smart_voice_alarm/core/navigation/root_navigator.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';
import 'package:smart_voice_alarm/router/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ChallengeLaunchCoordinator.instance.resetForTests();
  });

  IosPendingChallenge sample({
    String parent = 'alarm-1',
    String occ = 'occ-1',
  }) {
    return IosPendingChallenge(
      parentAlarmId: parent,
      occurrenceId: occ,
      childId: 'child-1',
      segmentIndex: 0,
      scheduledTimestamp: 1,
    );
  }

  group('ChallengeLaunchCoordinator', () {
    test('dedupes duplicate enqueue by parent+occurrence', () {
      final coordinator = ChallengeLaunchCoordinator.instance;
      coordinator.enqueue(sample());
      coordinator.enqueue(sample());
      expect(coordinator.isQueued('alarm-1', 'occ-1'), isTrue);
    });

    test('initialLocationFor returns challenge route and enqueues', () {
      final coordinator = ChallengeLaunchCoordinator.instance;
      final path = coordinator.initialLocationFor(sample());
      expect(
        path,
        AppRoutes.ringingPath(
          'alarm-1',
          challenge: true,
          occurrenceId: 'occ-1',
        ),
      );
      expect(coordinator.isQueued('alarm-1', 'occ-1'), isTrue);
    });

    testWidgets('navigates after router ready', (tester) async {
      final coordinator = ChallengeLaunchCoordinator.instance;
      coordinator.enqueue(sample(parent: 'a2', occ: 'o2'));

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('home')),
          ),
          GoRoute(
            path: AppRoutes.ringing,
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return Scaffold(body: Text('ringing:$id'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      coordinator.markRouterReady();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        GoRouter.of(rootNavigatorKey.currentContext!).state.uri.path,
        '/alarm/ringing/a2',
      );
    });

    testWidgets('does not navigate before router ready', (tester) async {
      final coordinator = ChallengeLaunchCoordinator.instance;
      coordinator.enqueue(sample(parent: 'a3', occ: 'o3'));

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('home')),
          ),
          GoRoute(
            path: AppRoutes.ringing,
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return Scaffold(body: Text('ringing:$id'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('home'), findsOneWidget);
      coordinator.markRouterReady();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        GoRouter.of(rootNavigatorKey.currentContext!).state.uri.path,
        '/alarm/ringing/a3',
      );
    });

    testWidgets('challenge initial route is not overwritten by home', (
      tester,
    ) async {
      final coordinator = ChallengeLaunchCoordinator.instance;
      final initial = coordinator.initialLocationFor(
        sample(parent: 'a4', occ: 'o4'),
      );

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: initial,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('home')),
          ),
          GoRoute(
            path: AppRoutes.ringing,
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return Scaffold(body: Text('ringing:$id'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      coordinator.markRouterReady();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        GoRouter.of(rootNavigatorKey.currentContext!).state.uri.path,
        '/alarm/ringing/a4',
      );
      expect(find.text('home'), findsNothing);
    });
  });
}
