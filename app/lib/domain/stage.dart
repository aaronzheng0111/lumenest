/// Pregnancy companion stage. Wire values match sdd/01 Plan.
enum Stage {
  prep,
  pregnant,
  delivery,
  postpartum,
}

extension StageX on Stage {
  /// AC-01-F01: only these four Chinese labels.
  String get label => switch (this) {
        Stage.prep => '备孕',
        Stage.pregnant => '孕期',
        Stage.delivery => '生产',
        Stage.postpartum => '产后',
      };

  static Stage fromWire(String? raw) {
    return switch (raw?.toUpperCase()) {
      'PREGNANT' => Stage.pregnant,
      'DELIVERY' => Stage.delivery,
      'POSTPARTUM' => Stage.postpartum,
      _ => Stage.prep,
    };
  }
}
