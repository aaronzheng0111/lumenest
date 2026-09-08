// Wire-string enums for Drift columns — values match
// `sdd/02-local-storage-and-domain/fixtures/enums.json` exactly.

abstract final class StageWire {
  static const prep = 'PREP';
  static const pregnant = 'PREGNANT';
  static const delivery = 'DELIVERY';
  static const postpartum = 'POSTPARTUM';
  static const all = [prep, pregnant, delivery, postpartum];
}

abstract final class AgentRoleWire {
  static const xiaonuan = 'XIAONUAN';
  static const lin = 'LIN';
  static const suxin = 'SUXIN';
  static const ama = 'AMA';
  static const all = [xiaonuan, lin, suxin, ama];
}

abstract final class ConversationTypeWire {
  static const solo = 'SOLO';
  static const group = 'GROUP';
  static const all = [solo, group];
}

abstract final class MessageRoleWire {
  static const user = 'user';
  static const assistant = 'assistant';
  static const system = 'system';
  static const all = [user, assistant, system];
}

abstract final class WeekUnitWire {
  static const pregnancyWeek = 'PREGNANCY_WEEK';
  static const postpartumWeek = 'POSTPARTUM_WEEK';
  static const all = [pregnancyWeek, postpartumWeek];
}

abstract final class ProfileCategoryWire {
  static const mood = 'MOOD';
  static const symptom = 'SYMPTOM';
  static const exam = 'EXAM';
  static const feeding = 'FEEDING';
  static const habit = 'HABIT';
  static const summary = 'SUMMARY';
  static const all = [mood, symptom, exam, feeding, habit, summary];
}

abstract final class PlanWire {
  static const free = 'FREE';
  static const companion = 'COMPANION';
  static const fullcare = 'FULLCARE';
  static const annual = 'ANNUAL';
  static const all = [free, companion, fullcare, annual];
}

abstract final class TaskStatusWire {
  static const pending = 'PENDING';
  static const done = 'DONE';
  static const skipped = 'SKIPPED';
  static const all = [pending, done, skipped];
}
