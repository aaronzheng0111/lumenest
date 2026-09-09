import 'dart:convert';

/// Sentinel for [RichUserProfile.copyWith] / [DailyCheckIn.copyWith]:
/// omit a parameter to keep the prior value; pass `null` to clear.
const Object _profileKeep = Object();

/// Optional tri-state for fields that allow "None / Not sure / Value".
enum FieldCertainty {
  unset,
  none,
  notSure,
  known,
}

extension FieldCertaintyX on FieldCertainty {
  String get wire => switch (this) {
        FieldCertainty.unset => 'UNSET',
        FieldCertainty.none => 'NONE',
        FieldCertainty.notSure => 'NOT_SURE',
        FieldCertainty.known => 'KNOWN',
      };

  String get label => switch (this) {
        FieldCertainty.unset => '未填写',
        FieldCertainty.none => '无',
        FieldCertainty.notSure => '不确定',
        FieldCertainty.known => '已填写',
      };

  static FieldCertainty fromWire(String? raw) => switch (raw?.toUpperCase()) {
        'NONE' => FieldCertainty.none,
        'NOT_SURE' => FieldCertainty.notSure,
        'KNOWN' => FieldCertainty.known,
        _ => FieldCertainty.unset,
      };
}

enum PregnancyStatus {
  unset,
  notPregnant,
  tryingToConceive,
  pregnant,
  postpartum,
}

extension PregnancyStatusX on PregnancyStatus {
  String get wire => switch (this) {
        PregnancyStatus.unset => 'UNSET',
        PregnancyStatus.notPregnant => 'NOT_PREGNANT',
        PregnancyStatus.tryingToConceive => 'TRYING',
        PregnancyStatus.pregnant => 'PREGNANT',
        PregnancyStatus.postpartum => 'POSTPARTUM',
      };

  String get label => switch (this) {
        PregnancyStatus.unset => '未填写',
        PregnancyStatus.notPregnant => '未怀孕',
        PregnancyStatus.tryingToConceive => '备孕中',
        PregnancyStatus.pregnant => '怀孕中',
        PregnancyStatus.postpartum => '产后',
      };

  static PregnancyStatus fromWire(String? raw) => switch (raw?.toUpperCase()) {
        'NOT_PREGNANT' => PregnancyStatus.notPregnant,
        'TRYING' => PregnancyStatus.tryingToConceive,
        'PREGNANT' => PregnancyStatus.pregnant,
        'POSTPARTUM' => PregnancyStatus.postpartum,
        _ => PregnancyStatus.unset,
      };
}

enum CommunicationStyle {
  unset,
  concise,
  detailed,
  friendly,
  professional,
}

extension CommunicationStyleX on CommunicationStyle {
  String get wire => name.toUpperCase();
  String get label => switch (this) {
        CommunicationStyle.unset => '未填写',
        CommunicationStyle.concise => '简洁',
        CommunicationStyle.detailed => '详细',
        CommunicationStyle.friendly => '亲切',
        CommunicationStyle.professional => '专业',
      };

  static CommunicationStyle fromWire(String? raw) =>
      switch (raw?.toUpperCase()) {
        'CONCISE' => CommunicationStyle.concise,
        'DETAILED' => CommunicationStyle.detailed,
        'FRIENDLY' => CommunicationStyle.friendly,
        'PROFESSIONAL' => CommunicationStyle.professional,
        _ => CommunicationStyle.unset,
      };
}

enum DietPreference {
  unset,
  vegetarian,
  vegan,
  halal,
  kosher,
  noPreference,
}

extension DietPreferenceX on DietPreference {
  String get wire => switch (this) {
        DietPreference.unset => 'UNSET',
        DietPreference.vegetarian => 'VEGETARIAN',
        DietPreference.vegan => 'VEGAN',
        DietPreference.halal => 'HALAL',
        DietPreference.kosher => 'KOSHER',
        DietPreference.noPreference => 'NO_PREFERENCE',
      };

  String get label => switch (this) {
        DietPreference.unset => '未填写',
        DietPreference.vegetarian => '素食',
        DietPreference.vegan => '纯素',
        DietPreference.halal => '清真',
        DietPreference.kosher => '洁食',
        DietPreference.noPreference => '无偏好',
      };

  static DietPreference fromWire(String? raw) => switch (raw?.toUpperCase()) {
        'VEGETARIAN' => DietPreference.vegetarian,
        'VEGAN' => DietPreference.vegan,
        'HALAL' => DietPreference.halal,
        'KOSHER' => DietPreference.kosher,
        'NO_PREFERENCE' => DietPreference.noPreference,
        _ => DietPreference.unset,
      };
}

enum UnitSystem { unset, metric, imperial }

extension UnitSystemX on UnitSystem {
  String get wire => name.toUpperCase();
  String get label => switch (this) {
        UnitSystem.unset => '未填写',
        UnitSystem.metric => '公制 (kg/cm)',
        UnitSystem.imperial => '英制 (lb/ft)',
      };

  static UnitSystem fromWire(String? raw) => switch (raw?.toUpperCase()) {
        'METRIC' => UnitSystem.metric,
        'IMPERIAL' => UnitSystem.imperial,
        _ => UnitSystem.unset,
      };
}

enum HealthcarePreference { unset, hospital, clinic, midwife }

extension HealthcarePreferenceX on HealthcarePreference {
  String get wire => name.toUpperCase();
  String get label => switch (this) {
        HealthcarePreference.unset => '未填写',
        HealthcarePreference.hospital => '医院',
        HealthcarePreference.clinic => '诊所',
        HealthcarePreference.midwife => '助产士',
      };

  static HealthcarePreference fromWire(String? raw) =>
      switch (raw?.toUpperCase()) {
        'HOSPITAL' => HealthcarePreference.hospital,
        'CLINIC' => HealthcarePreference.clinic,
        'MIDWIFE' => HealthcarePreference.midwife,
        _ => HealthcarePreference.unset,
      };
}

/// One medication / supplement entry.
final class MedicationEntry {
  const MedicationEntry({
    required this.name,
    this.dosage,
    this.frequency,
    this.startDate,
    this.isPrenatalVitamin = false,
    this.isSupplement = false,
  });

  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime? startDate;
  final bool isPrenatalVitamin;
  final bool isSupplement;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (dosage != null) 'dosage': dosage,
        if (frequency != null) 'frequency': frequency,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        'isPrenatalVitamin': isPrenatalVitamin,
        'isSupplement': isSupplement,
      };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      startDate: _parseDate(json['startDate']),
      isPrenatalVitamin: json['isPrenatalVitamin'] == true,
      isSupplement: json['isSupplement'] == true,
    );
  }
}

/// Allergy list with certainty (None / Not sure / listed).
final class AllergyBag {
  const AllergyBag({
    this.certainty = FieldCertainty.unset,
    this.medication = const [],
    this.food = const [],
    this.environmental = const [],
    this.other = const [],
  });

  final FieldCertainty certainty;
  final List<String> medication;
  final List<String> food;
  final List<String> environmental;
  final List<String> other;

  int get listedCount =>
      medication.length + food.length + environmental.length + other.length;

  String get summaryLabel {
    switch (certainty) {
      case FieldCertainty.none:
        return '无过敏';
      case FieldCertainty.notSure:
        return '不确定';
      case FieldCertainty.known:
        return listedCount == 0 ? '已记录' : '$listedCount 项过敏';
      case FieldCertainty.unset:
        return '未填写';
    }
  }

  AllergyBag copyWith({
    FieldCertainty? certainty,
    List<String>? medication,
    List<String>? food,
    List<String>? environmental,
    List<String>? other,
  }) {
    return AllergyBag(
      certainty: certainty ?? this.certainty,
      medication: medication ?? this.medication,
      food: food ?? this.food,
      environmental: environmental ?? this.environmental,
      other: other ?? this.other,
    );
  }

  Map<String, dynamic> toJson() => {
        'certainty': certainty.wire,
        'medication': medication,
        'food': food,
        'environmental': environmental,
        'other': other,
      };

  factory AllergyBag.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AllergyBag();
    return AllergyBag(
      certainty: FieldCertaintyX.fromWire(json['certainty'] as String?),
      medication: _stringList(json['medication']),
      food: _stringList(json['food']),
      environmental: _stringList(json['environmental']),
      other: _stringList(json['other']),
    );
  }
}

/// Today's compact check-in strip.
final class DailyCheckIn {
  const DailyCheckIn({
    this.localDate,
    this.waterMl,
    this.weightKg,
    this.sleepHours,
    this.steps,
    this.nutritionNote,
    this.mood,
    this.babyMovementCount,
    this.prenatalVitaminTaken,
  });

  final DateTime? localDate;
  final double? waterMl;
  final double? weightKg;
  final double? sleepHours;
  final int? steps;
  final String? nutritionNote;
  final String? mood;
  final int? babyMovementCount;
  final bool? prenatalVitaminTaken;

  DailyCheckIn copyWith({
    Object? localDate = _profileKeep,
    Object? waterMl = _profileKeep,
    Object? weightKg = _profileKeep,
    Object? sleepHours = _profileKeep,
    Object? steps = _profileKeep,
    Object? nutritionNote = _profileKeep,
    Object? mood = _profileKeep,
    Object? babyMovementCount = _profileKeep,
    Object? prenatalVitaminTaken = _profileKeep,
  }) {
    return DailyCheckIn(
      localDate: identical(localDate, _profileKeep)
          ? this.localDate
          : localDate as DateTime?,
      waterMl: identical(waterMl, _profileKeep)
          ? this.waterMl
          : waterMl as double?,
      weightKg: identical(weightKg, _profileKeep)
          ? this.weightKg
          : weightKg as double?,
      sleepHours: identical(sleepHours, _profileKeep)
          ? this.sleepHours
          : sleepHours as double?,
      steps: identical(steps, _profileKeep) ? this.steps : steps as int?,
      nutritionNote: identical(nutritionNote, _profileKeep)
          ? this.nutritionNote
          : nutritionNote as String?,
      mood: identical(mood, _profileKeep) ? this.mood : mood as String?,
      babyMovementCount: identical(babyMovementCount, _profileKeep)
          ? this.babyMovementCount
          : babyMovementCount as int?,
      prenatalVitaminTaken: identical(prenatalVitaminTaken, _profileKeep)
          ? this.prenatalVitaminTaken
          : prenatalVitaminTaken as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (localDate != null) 'localDate': _dateWire(localDate!),
        if (waterMl != null) 'waterMl': waterMl,
        if (weightKg != null) 'weightKg': weightKg,
        if (sleepHours != null) 'sleepHours': sleepHours,
        if (steps != null) 'steps': steps,
        if (nutritionNote != null) 'nutritionNote': nutritionNote,
        if (mood != null) 'mood': mood,
        if (babyMovementCount != null) 'babyMovementCount': babyMovementCount,
        if (prenatalVitaminTaken != null)
          'prenatalVitaminTaken': prenatalVitaminTaken,
      };

  factory DailyCheckIn.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DailyCheckIn();
    return DailyCheckIn(
      localDate: _parseDate(json['localDate']),
      waterMl: (json['waterMl'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      steps: json['steps'] as int?,
      nutritionNote: json['nutritionNote'] as String?,
      mood: json['mood'] as String?,
      babyMovementCount: json['babyMovementCount'] as int?,
      prenatalVitaminTaken: json['prenatalVitaminTaken'] as bool?,
    );
  }
}

/// Symptom log entry (optional fields).
final class SymptomLog {
  const SymptomLog({
    this.morningSickness,
    this.nausea,
    this.vomiting,
    this.fatigue,
    this.backPain,
    this.headache,
    this.heartburn,
    this.swelling,
    this.constipation,
    this.dizziness,
    this.abdominalDiscomfort,
    this.mood,
    this.sleepQuality,
    this.babyMovement,
    this.kickCount,
    this.loggedAt,
  });

  final String? morningSickness;
  final String? nausea;
  final String? vomiting;
  final String? fatigue;
  final String? backPain;
  final String? headache;
  final String? heartburn;
  final String? swelling;
  final String? constipation;
  final String? dizziness;
  final String? abdominalDiscomfort;
  final String? mood;
  final String? sleepQuality;
  final String? babyMovement;
  final int? kickCount;
  final DateTime? loggedAt;

  Map<String, dynamic> toJson() => {
        if (morningSickness != null) 'morningSickness': morningSickness,
        if (nausea != null) 'nausea': nausea,
        if (vomiting != null) 'vomiting': vomiting,
        if (fatigue != null) 'fatigue': fatigue,
        if (backPain != null) 'backPain': backPain,
        if (headache != null) 'headache': headache,
        if (heartburn != null) 'heartburn': heartburn,
        if (swelling != null) 'swelling': swelling,
        if (constipation != null) 'constipation': constipation,
        if (dizziness != null) 'dizziness': dizziness,
        if (abdominalDiscomfort != null)
          'abdominalDiscomfort': abdominalDiscomfort,
        if (mood != null) 'mood': mood,
        if (sleepQuality != null) 'sleepQuality': sleepQuality,
        if (babyMovement != null) 'babyMovement': babyMovement,
        if (kickCount != null) 'kickCount': kickCount,
        if (loggedAt != null) 'loggedAt': loggedAt!.toIso8601String(),
      };

  factory SymptomLog.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SymptomLog();
    return SymptomLog(
      morningSickness: json['morningSickness'] as String?,
      nausea: json['nausea'] as String?,
      vomiting: json['vomiting'] as String?,
      fatigue: json['fatigue'] as String?,
      backPain: json['backPain'] as String?,
      headache: json['headache'] as String?,
      heartburn: json['heartburn'] as String?,
      swelling: json['swelling'] as String?,
      constipation: json['constipation'] as String?,
      dizziness: json['dizziness'] as String?,
      abdominalDiscomfort: json['abdominalDiscomfort'] as String?,
      mood: json['mood'] as String?,
      sleepQuality: json['sleepQuality'] as String?,
      babyMovement: json['babyMovement'] as String?,
      kickCount: json['kickCount'] as int?,
      loggedAt: _parseDate(json['loggedAt']),
    );
  }
}

/// Comprehensive local profile. Stage/LMP/due/birth stay on the Users table;
/// this blob holds the rich optional fields for UI + agent context.
final class RichUserProfile {
  const RichUserProfile({
    this.photoPath,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.occupation,
    this.relationshipStatus,
    this.emergencyContact,
    this.pregnancyStatus = PregnancyStatus.unset,
    this.pregnancyWeekOverride,
    this.dueDateOverride,
    this.isFirstPregnancy,
    this.previousPregnancies,
    this.numberOfChildren,
    this.estimatedConceptionDate,
    this.fertilityTreatment,
    this.previousPregnancyHistory,
    this.previousMiscarriageOrComplications,
    this.preferredMaternityHospital,
    this.obGynProvider,
    this.bloodType,
    this.heightCm,
    this.currentWeightKg,
    this.prePregnancyWeightKg,
    this.targetWeightMinKg,
    this.targetWeightMaxKg,
    this.bloodPressure,
    this.medicalConditions = const [],
    this.previousSurgeries = const [],
    this.chronicConditions = const [],
    this.familyMedicalHistory,
    this.mentalWellbeing,
    this.vaccinationStatus,
    this.allergies = const AllergyBag(),
    this.medicationsCertainty = FieldCertainty.unset,
    this.medications = const [],
    this.dailyWaterGoalMl,
    this.typicalSleepHours,
    this.sleepQuality,
    this.dailyStepsGoal,
    this.exerciseFrequency,
    this.exerciseType,
    this.caffeine,
    this.alcohol,
    this.smoking,
    this.dietPreference = DietPreference.unset,
    this.foodPreferences = const [],
    this.foodsAvoided = const [],
    this.nutritionalGoals,
    this.latestSymptoms = const SymptomLog(),
    this.favoriteFoods = const [],
    this.dislikedFoods = const [],
    this.favoriteActivities = const [],
    this.exercisePreference,
    this.communicationStyle = CommunicationStyle.unset,
    this.reminderPreference,
    this.notificationFrequency,
    this.preferredReminderTime,
    this.language,
    this.units = UnitSystem.unset,
    this.healthcarePreference = HealthcarePreference.unset,
    this.todayCheckIn = const DailyCheckIn(),
  });

  final String? photoPath;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final String? occupation;
  final String? relationshipStatus;
  final String? emergencyContact;

  final PregnancyStatus pregnancyStatus;
  final int? pregnancyWeekOverride;
  final DateTime? dueDateOverride;
  final bool? isFirstPregnancy;
  final int? previousPregnancies;
  final int? numberOfChildren;
  final DateTime? estimatedConceptionDate;
  final String? fertilityTreatment;
  final String? previousPregnancyHistory;
  final String? previousMiscarriageOrComplications;
  final String? preferredMaternityHospital;
  final String? obGynProvider;

  final String? bloodType;
  final double? heightCm;
  final double? currentWeightKg;
  final double? prePregnancyWeightKg;
  final double? targetWeightMinKg;
  final double? targetWeightMaxKg;
  final String? bloodPressure;
  final List<String> medicalConditions;
  final List<String> previousSurgeries;
  final List<String> chronicConditions;
  final String? familyMedicalHistory;
  final String? mentalWellbeing;
  final String? vaccinationStatus;

  final AllergyBag allergies;
  final FieldCertainty medicationsCertainty;
  final List<MedicationEntry> medications;

  final double? dailyWaterGoalMl;
  final double? typicalSleepHours;
  final String? sleepQuality;
  final int? dailyStepsGoal;
  final String? exerciseFrequency;
  final String? exerciseType;
  final String? caffeine;
  final String? alcohol;
  final String? smoking;
  final DietPreference dietPreference;
  final List<String> foodPreferences;
  final List<String> foodsAvoided;
  final String? nutritionalGoals;

  final SymptomLog latestSymptoms;

  final List<String> favoriteFoods;
  final List<String> dislikedFoods;
  final List<String> favoriteActivities;
  final String? exercisePreference;
  final CommunicationStyle communicationStyle;
  final String? reminderPreference;
  final String? notificationFrequency;
  final String? preferredReminderTime;
  final String? language;
  final UnitSystem units;
  final HealthcarePreference healthcarePreference;

  final DailyCheckIn todayCheckIn;

  /// Age in whole years from [dateOfBirth], or null.
  int? ageYears({DateTime? today}) {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final t = today ?? DateTime.now();
    var age = t.year - dob.year;
    if (t.month < dob.month || (t.month == dob.month && t.day < dob.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  /// BMI from height/weight when both present.
  double? get bmi {
    final h = heightCm;
    final w = currentWeightKg;
    if (h == null || w == null || h <= 0) return null;
    final m = h / 100;
    return w / (m * m);
  }

  /// Trimester 1–3 from pregnancy week when known.
  int? trimesterFromWeek(int? week) {
    if (week == null || week < 1) return null;
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  int get healthDetailCount {
    var n = 0;
    if (bloodType != null && bloodType!.isNotEmpty) n++;
    if (heightCm != null) n++;
    if (currentWeightKg != null) n++;
    if (prePregnancyWeightKg != null) n++;
    if (bloodPressure != null && bloodPressure!.isNotEmpty) n++;
    n += medicalConditions.length;
    n += previousSurgeries.length;
    n += chronicConditions.length;
    if (familyMedicalHistory != null && familyMedicalHistory!.isNotEmpty) n++;
    if (mentalWellbeing != null && mentalWellbeing!.isNotEmpty) n++;
    if (vaccinationStatus != null && vaccinationStatus!.isNotEmpty) n++;
    return n;
  }

  String get medicationsSummary {
    switch (medicationsCertainty) {
      case FieldCertainty.none:
        return '无用药';
      case FieldCertainty.notSure:
        return '不确定';
      case FieldCertainty.known:
        return medications.isEmpty
            ? '已记录'
            : '${medications.length} 种药物/补充剂';
      case FieldCertainty.unset:
        return '未填写';
    }
  }

  /// Returns a copy; omitted fields stay unchanged, explicit `null` clears.
  RichUserProfile copyWith({
    Object? photoPath = _profileKeep,
    Object? fullName = _profileKeep,
    Object? dateOfBirth = _profileKeep,
    Object? gender = _profileKeep,
    Object? location = _profileKeep,
    Object? occupation = _profileKeep,
    Object? relationshipStatus = _profileKeep,
    Object? emergencyContact = _profileKeep,
    Object? pregnancyStatus = _profileKeep,
    Object? pregnancyWeekOverride = _profileKeep,
    Object? dueDateOverride = _profileKeep,
    Object? isFirstPregnancy = _profileKeep,
    Object? previousPregnancies = _profileKeep,
    Object? numberOfChildren = _profileKeep,
    Object? estimatedConceptionDate = _profileKeep,
    Object? fertilityTreatment = _profileKeep,
    Object? previousPregnancyHistory = _profileKeep,
    Object? previousMiscarriageOrComplications = _profileKeep,
    Object? preferredMaternityHospital = _profileKeep,
    Object? obGynProvider = _profileKeep,
    Object? bloodType = _profileKeep,
    Object? heightCm = _profileKeep,
    Object? currentWeightKg = _profileKeep,
    Object? prePregnancyWeightKg = _profileKeep,
    Object? targetWeightMinKg = _profileKeep,
    Object? targetWeightMaxKg = _profileKeep,
    Object? bloodPressure = _profileKeep,
    Object? medicalConditions = _profileKeep,
    Object? previousSurgeries = _profileKeep,
    Object? chronicConditions = _profileKeep,
    Object? familyMedicalHistory = _profileKeep,
    Object? mentalWellbeing = _profileKeep,
    Object? vaccinationStatus = _profileKeep,
    Object? allergies = _profileKeep,
    Object? medicationsCertainty = _profileKeep,
    Object? medications = _profileKeep,
    Object? dailyWaterGoalMl = _profileKeep,
    Object? typicalSleepHours = _profileKeep,
    Object? sleepQuality = _profileKeep,
    Object? dailyStepsGoal = _profileKeep,
    Object? exerciseFrequency = _profileKeep,
    Object? exerciseType = _profileKeep,
    Object? caffeine = _profileKeep,
    Object? alcohol = _profileKeep,
    Object? smoking = _profileKeep,
    Object? dietPreference = _profileKeep,
    Object? foodPreferences = _profileKeep,
    Object? foodsAvoided = _profileKeep,
    Object? nutritionalGoals = _profileKeep,
    Object? latestSymptoms = _profileKeep,
    Object? favoriteFoods = _profileKeep,
    Object? dislikedFoods = _profileKeep,
    Object? favoriteActivities = _profileKeep,
    Object? exercisePreference = _profileKeep,
    Object? communicationStyle = _profileKeep,
    Object? reminderPreference = _profileKeep,
    Object? notificationFrequency = _profileKeep,
    Object? preferredReminderTime = _profileKeep,
    Object? language = _profileKeep,
    Object? units = _profileKeep,
    Object? healthcarePreference = _profileKeep,
    Object? todayCheckIn = _profileKeep,
  }) {
    T keepOr<T>(Object? value, T current) =>
        identical(value, _profileKeep) ? current : value as T;

    return RichUserProfile(
      photoPath: keepOr(photoPath, this.photoPath),
      fullName: keepOr(fullName, this.fullName),
      dateOfBirth: keepOr(dateOfBirth, this.dateOfBirth),
      gender: keepOr(gender, this.gender),
      location: keepOr(location, this.location),
      occupation: keepOr(occupation, this.occupation),
      relationshipStatus:
          keepOr(relationshipStatus, this.relationshipStatus),
      emergencyContact: keepOr(emergencyContact, this.emergencyContact),
      pregnancyStatus: keepOr(pregnancyStatus, this.pregnancyStatus),
      pregnancyWeekOverride:
          keepOr(pregnancyWeekOverride, this.pregnancyWeekOverride),
      dueDateOverride: keepOr(dueDateOverride, this.dueDateOverride),
      isFirstPregnancy: keepOr(isFirstPregnancy, this.isFirstPregnancy),
      previousPregnancies:
          keepOr(previousPregnancies, this.previousPregnancies),
      numberOfChildren: keepOr(numberOfChildren, this.numberOfChildren),
      estimatedConceptionDate:
          keepOr(estimatedConceptionDate, this.estimatedConceptionDate),
      fertilityTreatment:
          keepOr(fertilityTreatment, this.fertilityTreatment),
      previousPregnancyHistory:
          keepOr(previousPregnancyHistory, this.previousPregnancyHistory),
      previousMiscarriageOrComplications: keepOr(
        previousMiscarriageOrComplications,
        this.previousMiscarriageOrComplications,
      ),
      preferredMaternityHospital: keepOr(
        preferredMaternityHospital,
        this.preferredMaternityHospital,
      ),
      obGynProvider: keepOr(obGynProvider, this.obGynProvider),
      bloodType: keepOr(bloodType, this.bloodType),
      heightCm: keepOr(heightCm, this.heightCm),
      currentWeightKg: keepOr(currentWeightKg, this.currentWeightKg),
      prePregnancyWeightKg:
          keepOr(prePregnancyWeightKg, this.prePregnancyWeightKg),
      targetWeightMinKg: keepOr(targetWeightMinKg, this.targetWeightMinKg),
      targetWeightMaxKg: keepOr(targetWeightMaxKg, this.targetWeightMaxKg),
      bloodPressure: keepOr(bloodPressure, this.bloodPressure),
      medicalConditions: keepOr(medicalConditions, this.medicalConditions),
      previousSurgeries: keepOr(previousSurgeries, this.previousSurgeries),
      chronicConditions: keepOr(chronicConditions, this.chronicConditions),
      familyMedicalHistory:
          keepOr(familyMedicalHistory, this.familyMedicalHistory),
      mentalWellbeing: keepOr(mentalWellbeing, this.mentalWellbeing),
      vaccinationStatus: keepOr(vaccinationStatus, this.vaccinationStatus),
      allergies: keepOr(allergies, this.allergies),
      medicationsCertainty:
          keepOr(medicationsCertainty, this.medicationsCertainty),
      medications: keepOr(medications, this.medications),
      dailyWaterGoalMl: keepOr(dailyWaterGoalMl, this.dailyWaterGoalMl),
      typicalSleepHours: keepOr(typicalSleepHours, this.typicalSleepHours),
      sleepQuality: keepOr(sleepQuality, this.sleepQuality),
      dailyStepsGoal: keepOr(dailyStepsGoal, this.dailyStepsGoal),
      exerciseFrequency: keepOr(exerciseFrequency, this.exerciseFrequency),
      exerciseType: keepOr(exerciseType, this.exerciseType),
      caffeine: keepOr(caffeine, this.caffeine),
      alcohol: keepOr(alcohol, this.alcohol),
      smoking: keepOr(smoking, this.smoking),
      dietPreference: keepOr(dietPreference, this.dietPreference),
      foodPreferences: keepOr(foodPreferences, this.foodPreferences),
      foodsAvoided: keepOr(foodsAvoided, this.foodsAvoided),
      nutritionalGoals: keepOr(nutritionalGoals, this.nutritionalGoals),
      latestSymptoms: keepOr(latestSymptoms, this.latestSymptoms),
      favoriteFoods: keepOr(favoriteFoods, this.favoriteFoods),
      dislikedFoods: keepOr(dislikedFoods, this.dislikedFoods),
      favoriteActivities:
          keepOr(favoriteActivities, this.favoriteActivities),
      exercisePreference:
          keepOr(exercisePreference, this.exercisePreference),
      communicationStyle:
          keepOr(communicationStyle, this.communicationStyle),
      reminderPreference:
          keepOr(reminderPreference, this.reminderPreference),
      notificationFrequency:
          keepOr(notificationFrequency, this.notificationFrequency),
      preferredReminderTime:
          keepOr(preferredReminderTime, this.preferredReminderTime),
      language: keepOr(language, this.language),
      units: keepOr(units, this.units),
      healthcarePreference:
          keepOr(healthcarePreference, this.healthcarePreference),
      todayCheckIn: keepOr(todayCheckIn, this.todayCheckIn),
    );
  }

  /// Agent-facing summary — omits raw sensitive dumps; uses counts/abstracts.
  ///
  /// Pass [primaryLabel] / week / trimester from [EffectiveJourney] so identity
  /// stays Stage-SSOT (no second conflicting `妊娠状态=` line).
  String agentContextSummary({
    required String nickname,
    required String primaryLabel,
    int? weekValue,
    String? weekUnit,
    int? trimester,
    bool includePrenatalVitamin = false,
    bool includeBabyMovement = false,
  }) {
    final parts = <String>[];
    parts.add('昵称=$nickname');
    final display = fullName?.trim();
    if (display != null && display.isNotEmpty) parts.add('姓名=$display');
    final age = ageYears();
    if (age != null) parts.add('年龄=$age');
    if (gender != null && gender!.isNotEmpty) parts.add('性别=$gender');
    if (location != null && location!.isNotEmpty) parts.add('地区=$location');
    if (occupation != null && occupation!.isNotEmpty) {
      parts.add('职业=$occupation');
    }
    parts.add('阶段=$primaryLabel');
    if (weekValue != null) {
      parts.add('周次=$weekValue${weekUnit ?? ''}');
    }
    if (trimester != null) {
      parts.add('孕期=$trimester');
    }
    if (numberOfChildren != null) parts.add('子女数=$numberOfChildren');
    if (dietPreference != DietPreference.unset) {
      parts.add('饮食=${dietPreference.label}');
    }
    if (favoriteFoods.isNotEmpty) {
      parts.add('爱吃=${favoriteFoods.take(5).join("、")}');
    }
    if (dislikedFoods.isNotEmpty) {
      parts.add('不爱吃=${dislikedFoods.take(5).join("、")}');
    }
    if (communicationStyle != CommunicationStyle.unset) {
      parts.add('沟通=${communicationStyle.label}');
    }
    if (language != null && language!.isNotEmpty) parts.add('语言=$language');
    if (units != UnitSystem.unset) parts.add('单位=${units.label}');
    parts.add('过敏=${allergies.summaryLabel}');
    parts.add('用药=$medicationsSummary');
    if (healthDetailCount > 0) {
      parts.add('健康明细数=$healthDetailCount');
    }
    final check = todayCheckIn;
    final todayBits = <String>[];
    if (check.waterMl != null) todayBits.add('饮水${check.waterMl!.round()}ml');
    if (check.weightKg != null) todayBits.add('体重${check.weightKg}kg');
    if (check.sleepHours != null) todayBits.add('睡眠${check.sleepHours}h');
    if (check.steps != null) todayBits.add('步数${check.steps}');
    if (check.mood != null) todayBits.add('心情${check.mood}');
    if (includePrenatalVitamin && check.prenatalVitaminTaken == true) {
      todayBits.add('已服叶酸/孕维');
    }
    if (includeBabyMovement && check.babyMovementCount != null) {
      todayBits.add('胎动${check.babyMovementCount}');
    }
    if (todayBits.isNotEmpty) parts.add('今日=${todayBits.join("、")}');
    return parts.join('；');
  }

  Map<String, dynamic> toJson() => {
        if (photoPath != null) 'photoPath': photoPath,
        if (fullName != null) 'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': _dateWire(dateOfBirth!),
        if (gender != null) 'gender': gender,
        if (location != null) 'location': location,
        if (occupation != null) 'occupation': occupation,
        if (relationshipStatus != null)
          'relationshipStatus': relationshipStatus,
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
        'pregnancyStatus': pregnancyStatus.wire,
        if (pregnancyWeekOverride != null)
          'pregnancyWeekOverride': pregnancyWeekOverride,
        if (dueDateOverride != null)
          'dueDateOverride': _dateWire(dueDateOverride!),
        if (isFirstPregnancy != null) 'isFirstPregnancy': isFirstPregnancy,
        if (previousPregnancies != null)
          'previousPregnancies': previousPregnancies,
        if (numberOfChildren != null) 'numberOfChildren': numberOfChildren,
        if (estimatedConceptionDate != null)
          'estimatedConceptionDate': _dateWire(estimatedConceptionDate!),
        if (fertilityTreatment != null)
          'fertilityTreatment': fertilityTreatment,
        if (previousPregnancyHistory != null)
          'previousPregnancyHistory': previousPregnancyHistory,
        if (previousMiscarriageOrComplications != null)
          'previousMiscarriageOrComplications':
              previousMiscarriageOrComplications,
        if (preferredMaternityHospital != null)
          'preferredMaternityHospital': preferredMaternityHospital,
        if (obGynProvider != null) 'obGynProvider': obGynProvider,
        if (bloodType != null) 'bloodType': bloodType,
        if (heightCm != null) 'heightCm': heightCm,
        if (currentWeightKg != null) 'currentWeightKg': currentWeightKg,
        if (prePregnancyWeightKg != null)
          'prePregnancyWeightKg': prePregnancyWeightKg,
        if (targetWeightMinKg != null) 'targetWeightMinKg': targetWeightMinKg,
        if (targetWeightMaxKg != null) 'targetWeightMaxKg': targetWeightMaxKg,
        if (bloodPressure != null) 'bloodPressure': bloodPressure,
        'medicalConditions': medicalConditions,
        'previousSurgeries': previousSurgeries,
        'chronicConditions': chronicConditions,
        if (familyMedicalHistory != null)
          'familyMedicalHistory': familyMedicalHistory,
        if (mentalWellbeing != null) 'mentalWellbeing': mentalWellbeing,
        if (vaccinationStatus != null) 'vaccinationStatus': vaccinationStatus,
        'allergies': allergies.toJson(),
        'medicationsCertainty': medicationsCertainty.wire,
        'medications': medications.map((m) => m.toJson()).toList(),
        if (dailyWaterGoalMl != null) 'dailyWaterGoalMl': dailyWaterGoalMl,
        if (typicalSleepHours != null) 'typicalSleepHours': typicalSleepHours,
        if (sleepQuality != null) 'sleepQuality': sleepQuality,
        if (dailyStepsGoal != null) 'dailyStepsGoal': dailyStepsGoal,
        if (exerciseFrequency != null) 'exerciseFrequency': exerciseFrequency,
        if (exerciseType != null) 'exerciseType': exerciseType,
        if (caffeine != null) 'caffeine': caffeine,
        if (alcohol != null) 'alcohol': alcohol,
        if (smoking != null) 'smoking': smoking,
        'dietPreference': dietPreference.wire,
        'foodPreferences': foodPreferences,
        'foodsAvoided': foodsAvoided,
        if (nutritionalGoals != null) 'nutritionalGoals': nutritionalGoals,
        'latestSymptoms': latestSymptoms.toJson(),
        'favoriteFoods': favoriteFoods,
        'dislikedFoods': dislikedFoods,
        'favoriteActivities': favoriteActivities,
        if (exercisePreference != null)
          'exercisePreference': exercisePreference,
        'communicationStyle': communicationStyle.wire,
        if (reminderPreference != null)
          'reminderPreference': reminderPreference,
        if (notificationFrequency != null)
          'notificationFrequency': notificationFrequency,
        if (preferredReminderTime != null)
          'preferredReminderTime': preferredReminderTime,
        if (language != null) 'language': language,
        'units': units.wire,
        'healthcarePreference': healthcarePreference.wire,
        'todayCheckIn': todayCheckIn.toJson(),
      };

  factory RichUserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const RichUserProfile();
    final medsRaw = json['medications'];
    final meds = <MedicationEntry>[];
    if (medsRaw is List) {
      for (final item in medsRaw) {
        if (item is Map<String, dynamic>) {
          meds.add(MedicationEntry.fromJson(item));
        } else if (item is Map) {
          meds.add(MedicationEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return RichUserProfile(
      photoPath: json['photoPath'] as String?,
      fullName: json['fullName'] as String?,
      dateOfBirth: _parseDate(json['dateOfBirth']),
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      occupation: json['occupation'] as String?,
      relationshipStatus: json['relationshipStatus'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      pregnancyStatus:
          PregnancyStatusX.fromWire(json['pregnancyStatus'] as String?),
      pregnancyWeekOverride: json['pregnancyWeekOverride'] as int?,
      dueDateOverride: _parseDate(json['dueDateOverride']),
      isFirstPregnancy: json['isFirstPregnancy'] as bool?,
      previousPregnancies: json['previousPregnancies'] as int?,
      numberOfChildren: json['numberOfChildren'] as int?,
      estimatedConceptionDate: _parseDate(json['estimatedConceptionDate']),
      fertilityTreatment: json['fertilityTreatment'] as String?,
      previousPregnancyHistory: json['previousPregnancyHistory'] as String?,
      previousMiscarriageOrComplications:
          json['previousMiscarriageOrComplications'] as String?,
      preferredMaternityHospital: json['preferredMaternityHospital'] as String?,
      obGynProvider: json['obGynProvider'] as String?,
      bloodType: json['bloodType'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      prePregnancyWeightKg: (json['prePregnancyWeightKg'] as num?)?.toDouble(),
      targetWeightMinKg: (json['targetWeightMinKg'] as num?)?.toDouble(),
      targetWeightMaxKg: (json['targetWeightMaxKg'] as num?)?.toDouble(),
      bloodPressure: json['bloodPressure'] as String?,
      medicalConditions: _stringList(json['medicalConditions']),
      previousSurgeries: _stringList(json['previousSurgeries']),
      chronicConditions: _stringList(json['chronicConditions']),
      familyMedicalHistory: json['familyMedicalHistory'] as String?,
      mentalWellbeing: json['mentalWellbeing'] as String?,
      vaccinationStatus: json['vaccinationStatus'] as String?,
      allergies: AllergyBag.fromJson(
        json['allergies'] is Map
            ? Map<String, dynamic>.from(json['allergies'] as Map)
            : null,
      ),
      medicationsCertainty:
          FieldCertaintyX.fromWire(json['medicationsCertainty'] as String?),
      medications: meds,
      dailyWaterGoalMl: (json['dailyWaterGoalMl'] as num?)?.toDouble(),
      typicalSleepHours: (json['typicalSleepHours'] as num?)?.toDouble(),
      sleepQuality: json['sleepQuality'] as String?,
      dailyStepsGoal: json['dailyStepsGoal'] as int?,
      exerciseFrequency: json['exerciseFrequency'] as String?,
      exerciseType: json['exerciseType'] as String?,
      caffeine: json['caffeine'] as String?,
      alcohol: json['alcohol'] as String?,
      smoking: json['smoking'] as String?,
      dietPreference:
          DietPreferenceX.fromWire(json['dietPreference'] as String?),
      foodPreferences: _stringList(json['foodPreferences']),
      foodsAvoided: _stringList(json['foodsAvoided']),
      nutritionalGoals: json['nutritionalGoals'] as String?,
      latestSymptoms: SymptomLog.fromJson(
        json['latestSymptoms'] is Map
            ? Map<String, dynamic>.from(json['latestSymptoms'] as Map)
            : null,
      ),
      favoriteFoods: _stringList(json['favoriteFoods']),
      dislikedFoods: _stringList(json['dislikedFoods']),
      favoriteActivities: _stringList(json['favoriteActivities']),
      exercisePreference: json['exercisePreference'] as String?,
      communicationStyle:
          CommunicationStyleX.fromWire(json['communicationStyle'] as String?),
      reminderPreference: json['reminderPreference'] as String?,
      notificationFrequency: json['notificationFrequency'] as String?,
      preferredReminderTime: json['preferredReminderTime'] as String?,
      language: json['language'] as String?,
      units: UnitSystemX.fromWire(json['units'] as String?),
      healthcarePreference: HealthcarePreferenceX.fromWire(
        json['healthcarePreference'] as String?,
      ),
      todayCheckIn: DailyCheckIn.fromJson(
        json['todayCheckIn'] is Map
            ? Map<String, dynamic>.from(json['todayCheckIn'] as Map)
            : null,
      ),
    );
  }

  static RichUserProfile decode(String? raw) {
    if (raw == null || raw.isEmpty || raw == '{}') {
      return const RichUserProfile();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return RichUserProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return RichUserProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      return const RichUserProfile();
    } catch (_) {
      return const RichUserProfile();
    }
    return const RichUserProfile();
  }

  String encode() => jsonEncode(toJson());
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw.map((e) => '$e'.trim()).where((s) => s.isNotEmpty).toList();
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw);
  }
  return null;
}

String _dateWire(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
