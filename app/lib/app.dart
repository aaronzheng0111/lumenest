import 'package:flutter/material.dart';

import 'domain/agent_role.dart';
import 'features/chat/chat_session_page.dart';
import 'features/me/launch_privacy_notice_page.dart';
import 'features/shell/app_shell.dart';
import 'theme/app_theme.dart';

class AiMomBabyApp extends StatelessWidget {
  const AiMomBabyApp({
    super.key,
    this.navigatorObservers = const [],
    this.showLaunchNotice = true,
  });

  final List<NavigatorObserver> navigatorObservers;

  /// Every cold start shows the privacy status page. Tests set this false.
  final bool showLaunchNotice;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '孕育小家',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorObservers: navigatorObservers,
      initialRoute: '/',
      onGenerateRoute: (settings) => generateAppRoute(
        settings,
        showLaunchNotice: showLaunchNotice,
      ),
    );
  }
}

Route<void> generateAppRoute(
  RouteSettings settings, {
  bool showLaunchNotice = true,
}) {
  final uri = Uri.parse(settings.name ?? '/');
  if (uri.path == '/chat') {
    final role = AgentRoleX.fromWire(uri.queryParameters['role']);
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => ChatSessionPage(role: role),
    );
  }
  if (uri.path == '/me') {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const AppShell(initialTab: 2),
    );
  }
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => AppRoot(showLaunchNotice: showLaunchNotice),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, this.showLaunchNotice = true});

  final bool showLaunchNotice;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late bool _blocked;

  @override
  void initState() {
    super.initState();
    _blocked = widget.showLaunchNotice;
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) {
      return LaunchPrivacyNoticePage(
        onFinished: () {
          if (!mounted) return;
          setState(() => _blocked = false);
        },
      );
    }
    return const AppShell();
  }
}
