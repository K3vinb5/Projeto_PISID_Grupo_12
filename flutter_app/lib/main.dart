import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screens.dart';

void main() => runApp(const MyApp());

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _alertsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'alerts');
final GlobalKey<NavigatorState> _miceNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'mice');
final GlobalKey<NavigatorState> _sensor1NavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sensor1');
final GlobalKey<NavigatorState> _sensor2NavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sensor2');

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginFormScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return BottomNavigationBarScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _alertsNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/alerts',
              builder: (BuildContext context, GoRouterState state) =>
                  const AlertsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _miceNavigatorKey,
          routes: [
            GoRoute(
              path: '/mice',
              builder: (BuildContext context, GoRouterState state) =>
                  const ReadingsRoomScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sensor1NavigatorKey,
          routes: [
            GoRoute(
              path: '/sensors1',
              builder: (BuildContext context, GoRouterState state) =>
              const ReadingsTempScreen(sensor: 1),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sensor2NavigatorKey,
          routes: [
            GoRoute(
              path: '/sensors2',
              builder: (BuildContext context, GoRouterState state) =>
              const ReadingsTempScreen(sensor: 2),
            ),
          ],
        )
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: true,
      title: 'Monitorização Ratos',
      routerConfig: _router,
    );
  }
}
