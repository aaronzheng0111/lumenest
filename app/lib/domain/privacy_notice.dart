/// Startup / Me privacy copy. Loaded from `assets/fixtures/privacy-notice.json`.
class PrivacyNotice {
  const PrivacyNotice({
    required this.id,
    required this.version,
    required this.title,
    required this.statusLabel,
    required this.statusDetail,
    required this.body,
    required this.bullets,
    required this.primaryAction,
    required this.agreeAction,
  });

  final String id;
  final int version;
  final String title;
  final String statusLabel;
  final String statusDetail;
  final String body;
  final List<String> bullets;
  final String primaryAction;
  final String agreeAction;

  static const fallback = PrivacyNotice(
    id: 'fallback',
    version: 0,
    title: '隐私状况',
    statusLabel: '本地优先',
    statusDetail: '健康数据以设备本地为主。我们不上传整库。',
    body: '健康数据以设备本地为主。我们不上传整库。',
    bullets: [],
    primaryAction: '知道了',
    agreeAction: '同意并继续',
  );

  factory PrivacyNotice.fromJson(Map<String, dynamic> json) {
    return PrivacyNotice(
      id: json['id'] as String? ?? 'privacy-notice',
      version: json['version'] as int? ?? 1,
      title: json['title'] as String? ?? fallback.title,
      statusLabel: json['statusLabel'] as String? ?? '',
      statusDetail: json['statusDetail'] as String? ?? '',
      body: json['body'] as String? ?? fallback.body,
      bullets: (json['bullets'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      primaryAction: json['primaryAction'] as String? ?? fallback.primaryAction,
      agreeAction: json['agreeAction'] as String? ?? fallback.agreeAction,
    );
  }

  String get combinedBody => [
        statusDetail,
        body,
      ].where((s) => s.isNotEmpty).join('\n\n');
}
