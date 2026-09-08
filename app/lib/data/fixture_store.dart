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

/// Reads `assets/fixtures/mock-user.json` for cold-start demos without Drift edits.
class AssetMockUserProfileRepository implements UserProfileRepository {
  int getSnapshotCalls = 0;

  @override
  Future<UserProfileSnapshot> getSnapshot({DateTime? today}) async {
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

  @override
  Future<ProfileDraft> loadDraft() async {
    return const ProfileDraft(nickname: '妈妈');
  }

  @override
  Future<void> saveEdits(ProfileEdits edits, {DateTime? today}) async {
    // Mock asset store is read-only in P0 demos.
  }
}
