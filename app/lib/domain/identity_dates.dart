/// Calendar dates that drive [resolveStage] (users-table SSOT).
final class IdentityDates {
  const IdentityDates({
    this.lastMenstruationDate,
    this.dueDate,
    this.birthDate,
  });

  final DateTime? lastMenstruationDate;
  final DateTime? dueDate;
  final DateTime? birthDate;

  IdentityDates copyWith({
    Object? lastMenstruationDate = _keep,
    Object? dueDate = _keep,
    Object? birthDate = _keep,
  }) {
    return IdentityDates(
      lastMenstruationDate: identical(lastMenstruationDate, _keep)
          ? this.lastMenstruationDate
          : lastMenstruationDate as DateTime?,
      dueDate: identical(dueDate, _keep) ? this.dueDate : dueDate as DateTime?,
      birthDate:
          identical(birthDate, _keep) ? this.birthDate : birthDate as DateTime?,
    );
  }
}

const Object _keep = Object();
