class UserSettings {
  final int dailyWordLimit;

  UserSettings({required this.dailyWordLimit});

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(dailyWordLimit: json['dailyWordLimit']);
  }

  Map<String, dynamic> toJson() {
    return {'dailyWordLimit': dailyWordLimit};
  }
}
