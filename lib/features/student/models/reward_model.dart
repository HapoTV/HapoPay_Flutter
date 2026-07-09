/// reward_model.dart
/// Data models for the HapoPay Student Rewards System.
/// Mirrors the /api/rewards/{studentId}/ endpoint contract.
library;

// ---------------------------------------------------------------------------
// Tier
// ---------------------------------------------------------------------------

enum RewardTier { bronze, silver, gold, platinum }

extension RewardTierX on RewardTier {
  String get label {
    switch (this) {
      case RewardTier.bronze:
        return 'Bronze';
      case RewardTier.silver:
        return 'Silver';
      case RewardTier.gold:
        return 'Gold';
      case RewardTier.platinum:
        return 'Platinum';
    }
  }

  /// Emoji badge shown alongside tier name.
  String get badge {
    switch (this) {
      case RewardTier.bronze:
        return '🥉';
      case RewardTier.silver:
        return '🥈';
      case RewardTier.gold:
        return '🥇';
      case RewardTier.platinum:
        return '💎';
    }
  }

  static RewardTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'silver':
        return RewardTier.silver;
      case 'gold':
        return RewardTier.gold;
      case 'platinum':
        return RewardTier.platinum;
      default:
        return RewardTier.bronze;
    }
  }
}

// ---------------------------------------------------------------------------
// Achievement
// ---------------------------------------------------------------------------

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final bool earned;
  final bool claimed;
  final String icon; // maps to a Material icon name
  final int points;

  /// For in-progress achievements (e.g. "5-Day Saver: 3/5").
  final int? progress;
  final int? goal;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.earned,
    this.claimed = false,
    required this.icon,
    required this.points,
    this.progress,
    this.goal,
  });

  /// Progress fraction 0.0 – 1.0; null when no progress data.
  double? get progressFraction {
    if (progress == null || goal == null || goal == 0) return null;
    return (progress! / goal!).clamp(0.0, 1.0);
  }

  bool get hasProgress => progress != null && goal != null;

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      earned: json['earned'] as bool? ?? false,
      claimed: json['claimed'] as bool? ?? false,
      icon: json['icon'] as String? ?? 'emoji_events',
      points: json['points'] as int? ?? 0,
      progress: json['progress'] as int?,
      goal: json['goal'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'earned': earned,
        'claimed': claimed,
        'icon': icon,
        'points': points,
        if (progress != null) 'progress': progress,
        if (goal != null) 'goal': goal,
      };

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? earned,
    bool? claimed,
    String? icon,
    int? points,
    int? progress,
    int? goal,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      earned: earned ?? this.earned,
      claimed: claimed ?? this.claimed,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      progress: progress ?? this.progress,
      goal: goal ?? this.goal,
    );
  }
}

// ---------------------------------------------------------------------------
// Milestone
// ---------------------------------------------------------------------------

class MilestoneModel {
  final RewardTier tier;
  final int minPoints;
  final int? maxPoints; // null = no upper limit (platinum)

  const MilestoneModel({
    required this.tier,
    required this.minPoints,
    this.maxPoints,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      tier: RewardTierX.fromString(json['tier'] as String? ?? 'bronze'),
      minPoints: json['min_points'] as int? ?? 0,
      maxPoints: json['max_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'min_points': minPoints,
        if (maxPoints != null) 'max_points': maxPoints,
      };
}

// ---------------------------------------------------------------------------
// Root Reward Model
// ---------------------------------------------------------------------------

class RewardModel {
  final String studentId;
  final int totalPoints;
  final RewardTier tier;
  final List<AchievementModel> achievements;
  final List<MilestoneModel> milestones;

  /// Points needed to reach the next tier (null if already platinum).
  final int? nextMilestonePoints;

  /// Current consecutive days staying on-budget.
  final int streakDays;

  const RewardModel({
    required this.studentId,
    required this.totalPoints,
    required this.tier,
    required this.achievements,
    required this.milestones,
    this.nextMilestonePoints,
    this.streakDays = 0,
  });

  /// Progress fraction (0.0–1.0) within the current milestone band.
  double get tierProgressFraction {
    final currentMilestone =
        milestones.where((m) => m.tier == tier).firstOrNull;
    if (currentMilestone == null) return 0.0;
    final min = currentMilestone.minPoints;
    final max = currentMilestone.maxPoints;
    if (max == null) return 1.0; // platinum = full
    final range = max - min;
    if (range <= 0) return 1.0;
    return ((totalPoints - min) / range).clamp(0.0, 1.0);
  }

  int get earnedAchievementsCount => achievements.where((a) => a.earned).length;

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      studentId: json['student_id'] as String? ?? '',
      totalPoints: json['total_points'] as int? ?? 0,
      tier: RewardTierX.fromString(json['tier'] as String? ?? 'bronze'),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>? ?? [])
          .map((e) => MilestoneModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextMilestonePoints: json['next_milestone_points'] as int?,
      streakDays: json['streak_days'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'total_points': totalPoints,
        'tier': tier.name,
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
        if (nextMilestonePoints != null)
          'next_milestone_points': nextMilestonePoints,
        'streak_days': streakDays,
      };

  RewardModel copyWith({
    String? studentId,
    int? totalPoints,
    RewardTier? tier,
    List<AchievementModel>? achievements,
    List<MilestoneModel>? milestones,
    int? nextMilestonePoints,
    int? streakDays,
  }) {
    return RewardModel(
      studentId: studentId ?? this.studentId,
      totalPoints: totalPoints ?? this.totalPoints,
      tier: tier ?? this.tier,
      achievements: achievements ?? this.achievements,
      milestones: milestones ?? this.milestones,
      nextMilestonePoints: nextMilestonePoints ?? this.nextMilestonePoints,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  // ---------------------------------------------------------------------------
  // Fallback / demo data used when the backend is unreachable
  // ---------------------------------------------------------------------------
  static RewardModel demo() {
    return const RewardModel(
      studentId: 'demo',
      totalPoints: 480,
      tier: RewardTier.silver,
      streakDays: 7,
      nextMilestonePoints: 600,
      milestones: [
        MilestoneModel(tier: RewardTier.bronze, minPoints: 0, maxPoints: 200),
        MilestoneModel(tier: RewardTier.silver, minPoints: 200, maxPoints: 600),
        MilestoneModel(tier: RewardTier.gold, minPoints: 600, maxPoints: 1200),
        MilestoneModel(tier: RewardTier.platinum, minPoints: 1200),
      ],
      achievements: [
        AchievementModel(
          id: 'first_pay',
          name: 'First Payment',
          description: 'Completed your very first payment',
          earned: true,
          claimed: true,
          icon: 'payment',
          points: 50,
        ),
        AchievementModel(
          id: 'saver_5',
          name: '5-Day Saver',
          description: 'Stay under budget for 5 days straight',
          earned: false,
          icon: 'savings',
          points: 100,
          progress: 3,
          goal: 5,
        ),
        AchievementModel(
          id: 'qr_master',
          name: 'QR Master',
          description: 'Used QR scan to pay 10 times',
          earned: true,
          claimed: false,
          icon: 'qr_code_scanner',
          points: 75,
        ),
        AchievementModel(
          id: 'streak_14',
          name: '2-Week Warrior',
          description: 'Keep a 14-day budget streak',
          earned: false,
          icon: 'local_fire_department',
          points: 200,
          progress: 7,
          goal: 14,
        ),
        AchievementModel(
          id: 'big_saver',
          name: 'Big Saver',
          description: 'Save KSh 1,000 in a month',
          earned: false,
          icon: 'account_balance_wallet',
          points: 150,
          progress: 480,
          goal: 1000,
        ),
        AchievementModel(
          id: 'social_star',
          name: 'Social Star',
          description: 'Refer a friend to HapoPay',
          earned: true,
          claimed: true,
          icon: 'share',
          points: 100,
        ),
      ],
    );
  }
}
