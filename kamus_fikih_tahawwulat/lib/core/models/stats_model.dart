import 'package:flutter/foundation.dart';

@immutable
class Achievement {
  final String id;
  final String titleKey;
  final String descKey;
  final bool isUnlocked;
  final int currentProgress;
  final int targetProgress;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.isUnlocked,
    required this.currentProgress,
    required this.targetProgress,
  });
}

@immutable
class KamusStats {
  final int termsViewed;
  final int definitionsFavorited;
  final List<Achievement> achievements;

  const KamusStats({
    required this.termsViewed,
    required this.definitionsFavorited,
    required this.achievements,
  });

  factory KamusStats.compute({
    required int viewedCount,
    required int favoritedCount,
  }) {
    return KamusStats(
      termsViewed: viewedCount,
      definitionsFavorited: favoritedCount,
      achievements: [
        Achievement(
          id: 'novice_explorer',
          titleKey: 'noviceExplorer',
          descKey: 'noviceExplorerDesc',
          isUnlocked: viewedCount >= 10,
          currentProgress: viewedCount.clamp(0, 10),
          targetProgress: 10,
        ),
        Achievement(
          id: 'dedicated_scholar',
          titleKey: 'dedicatedScholar',
          descKey: 'dedicatedScholarDesc',
          isUnlocked: viewedCount >= 50,
          currentProgress: viewedCount.clamp(0, 50),
          targetProgress: 50,
        ),
        Achievement(
          id: 'pro_collector',
          titleKey: 'proCollector',
          descKey: 'proCollectorDesc',
          isUnlocked: favoritedCount >= 10,
          currentProgress: favoritedCount.clamp(0, 10),
          targetProgress: 10,
        ),
      ],
    );
  }
}
