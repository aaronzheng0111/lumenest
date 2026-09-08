import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/privacy_notice.dart';
import '../domain/stage.dart';
import '../domain/user_profile_snapshot.dart';
import 'user_profile_repository.dart';

const mockUserAssetPath = 'assets/fixtures/mock-user.json';
const privacyNoticeAssetPath = 'assets/fixtures/privacy-notice.json';

Future<PrivacyNotice> loadPrivacyNotice() async {
  try {
    final raw = await rootBundle.loadString(privacyNoticeAssetPath);
    return PrivacyNotice.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  } catch (_) {
    return PrivacyNotice.fallback;
  }
}

/// Reads `assets/fixtures/mock-user.json` until 03 ships a real store.
class AssetMockUserProfileRepository implements UserProfileRepository {
  int getSnapshotCalls = 0;

  @override
  Future<UserProfileSnapshot> getSnapshot() async {
    getSnapshotCalls++;
    try {
      final raw = await rootBundle.loadString(mockUserAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileSnapshot(
        stage: StageX.fromWire(json['stage'] as String?),
        weekValue: json['weekValue'] as int?,
        weekUnit: json['weekUnit'] as String?,
      );
    } catch (_) {
      return UserProfileSnapshot.fallback;
    }
  }
}
