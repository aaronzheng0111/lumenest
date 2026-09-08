import 'package:flutter/material.dart';

import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_tab_bar.dart';
import '../conversations/conversation_list_page.dart';
import '../home/home_page.dart';
import '../me/me_info_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  static const _tabs = [
    GlassTabItem(
      label: '首页',
      icon: Icons.home_rounded,
      tabKey: Key('nav_home'),
    ),
    GlassTabItem(
      label: '对话',
      icon: Icons.chat_bubble_rounded,
      tabKey: Key('nav_chat'),
    ),
    GlassTabItem(
      label: '我的',
      icon: Icons.person_rounded,
      tabKey: Key('nav_me'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          ConversationListPage(),
          MeInfoPage(),
        ],
      ),
      bottomNavigationBar: GlassTabBar(
        key: const Key('app_bottom_nav'),
        items: _tabs,
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Extra bottom inset so tab pages clear the floating pill.
double shellBottomInset(BuildContext context) {
  return MediaQuery.paddingOf(context).bottom +
      GlassTabBar.height +
      SpacingTokens.lg;
}
