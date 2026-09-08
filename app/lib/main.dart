import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'theme/glass_tokens.dart';
import 'theme/radius_tokens.dart';
import 'theme/spacing_tokens.dart';
import 'widgets/atmosphere_background.dart';
import 'widgets/glass/glass_app_bar.dart';
import 'widgets/glass/glass_container.dart';
import 'widgets/glass/glass_tab_bar.dart';

void main() {
  runApp(const AiMomBabyApp());
}

class AiMomBabyApp extends StatelessWidget {
  const AiMomBabyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '孕育小家',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const GlassTokenPreviewPage(),
    );
  }
}

/// Temporary home used to validate TASK-005 tokens / glass widgets.
/// Replaced by real Home / Chat / Me shell in TASK-101.
class GlassTokenPreviewPage extends StatefulWidget {
  const GlassTokenPreviewPage({super.key});

  @override
  State<GlassTokenPreviewPage> createState() => _GlassTokenPreviewPageState();
}

class _GlassTokenPreviewPageState extends State<GlassTokenPreviewPage> {
  int _tabIndex = 0;

  static const _tabs = [
    GlassTabItem(label: '首页', icon: Icons.home_rounded),
    GlassTabItem(label: '对话', icon: Icons.chat_bubble_rounded),
    GlassTabItem(label: '我的', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar.forContext(
        context,
        title: const Text('孕育小家'),
      ),
      body: AtmosphereBackground(
        child: Builder(
          builder: (context) {
            // Scaffold extendBody* inflates this padding to the app bar / tab bar
            // footprints so scroll extent clears chrome, while the list still
            // paints under the glass.
            final chrome = MediaQuery.paddingOf(context);
            return ListView(
              padding: EdgeInsets.fromLTRB(
                SpacingTokens.pageMargin,
                chrome.top + SpacingTokens.lg,
                SpacingTokens.pageMargin,
                chrome.bottom + SpacingTokens.lg,
              ),
              children: [
                GlassContainer(
                  fill: GlassFill.medium,
                  borderRadius: RadiusTokens.borderXl,
                  padding: const EdgeInsets.all(SpacingTokens.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('孕16周', style: textTheme.displaySmall),
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        'Liquid Glass Token 预览 · TASK-005',
                        style: textTheme.bodySmall?.copyWith(color: onVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        fill: GlassFill.rose,
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        child: Text('小暖 · 激活', style: textTheme.labelMedium),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: GlassContainer(
                        fill: GlassFill.locked,
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        child: Text(
                          '林医生 · 锁定',
                          style: textTheme.labelMedium?.copyWith(
                            color: onVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sectionGap),
                GlassContainer(
                  fill: GlassFill.light,
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Text(
                    '默认玻璃卡片：半透明 + BackdropFilter 模糊 + 高光描边。',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: GlassTabBar(
        items: _tabs,
        currentIndex: _tabIndex,
        onChanged: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
