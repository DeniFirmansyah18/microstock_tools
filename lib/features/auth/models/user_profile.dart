enum UserTier {
  free,
  pro,
}

class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final UserTier tier;
  final int quotaUsedToday;
  final int maxDailyQuota;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.tier = UserTier.free,
    this.quotaUsedToday = 0,
    this.maxDailyQuota = 50,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    UserTier? tier,
    int? quotaUsedToday,
    int? maxDailyQuota,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      tier: tier ?? this.tier,
      quotaUsedToday: quotaUsedToday ?? this.quotaUsedToday,
      maxDailyQuota: maxDailyQuota ?? this.maxDailyQuota,
    );
  }
}
