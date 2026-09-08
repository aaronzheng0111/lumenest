import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'app.dart';
import 'providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        dataExporterProvider.overrideWithValue(
          (json) => Share.share(json, subject: '我的孕育数据'),
        ),
      ],
      child: const AiMomBabyApp(),
    ),
  );
}
