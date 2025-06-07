class ConfigurationModel {
  final String id;
  final String activationMode;
  final bool isInternetDisabled;
  final bool isTabSwitchDisabled;

  ConfigurationModel({
    required this.id,
    required this.activationMode,
    required this.isInternetDisabled,
    required this.isTabSwitchDisabled,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'] ?? '',
      activationMode: json['activationMode'] ?? '',
      // isInternetDisabled: json['isInternetDisabled'] ?? false,
      isInternetDisabled: false,
      isTabSwitchDisabled: json['isTabSwitchDisabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activationMode': activationMode,
      'isInternetDisabled': isInternetDisabled,
      'isTabSwitchDisabled': isTabSwitchDisabled,
    };
  }

  static ConfigurationModel toEmpty() {
    return ConfigurationModel(
      id: '',
      activationMode: '',
      isInternetDisabled: false,
      isTabSwitchDisabled: false,
    );
  }
}
