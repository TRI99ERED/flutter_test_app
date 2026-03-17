class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool messageNotificationsEnabled;
  final bool friendRequestNotificationsEnabled;
  final bool projectInviteNotificationsEnabled;

  const NotificationSettings({
    required this.pushNotificationsEnabled,
    required this.messageNotificationsEnabled,
    required this.friendRequestNotificationsEnabled,
    required this.projectInviteNotificationsEnabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotificationsEnabled: json['notificationsEnabled'] ?? true,
      messageNotificationsEnabled: json['messageNotificationsEnabled'] ?? true,
      friendRequestNotificationsEnabled:
          json['friendRequestNotificationsEnabled'] ?? true,
      projectInviteNotificationsEnabled:
          json['projectInviteNotificationsEnabled'] ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? messageNotificationsEnabled,
    bool? friendRequestNotificationsEnabled,
    bool? projectInviteNotificationsEnabled,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      messageNotificationsEnabled:
          messageNotificationsEnabled ?? this.messageNotificationsEnabled,
      friendRequestNotificationsEnabled:
          friendRequestNotificationsEnabled ??
          this.friendRequestNotificationsEnabled,
      projectInviteNotificationsEnabled:
          projectInviteNotificationsEnabled ??
          this.projectInviteNotificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.pushNotificationsEnabled == pushNotificationsEnabled &&
        other.messageNotificationsEnabled == messageNotificationsEnabled &&
        other.friendRequestNotificationsEnabled ==
            friendRequestNotificationsEnabled &&
        other.projectInviteNotificationsEnabled ==
            projectInviteNotificationsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      pushNotificationsEnabled,
      messageNotificationsEnabled,
      friendRequestNotificationsEnabled,
      projectInviteNotificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': pushNotificationsEnabled,
      'messageNotificationsEnabled': messageNotificationsEnabled,
      'friendRequestNotificationsEnabled': friendRequestNotificationsEnabled,
      'projectInviteNotificationsEnabled': projectInviteNotificationsEnabled,
    };
  }
}
