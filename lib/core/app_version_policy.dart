import 'dart:convert';

class AppVersionPolicy {
  final String platform;
  final String? currentVersion;
  final int? currentBuild;
  final bool forceUpdate;
  final String comparisonMode;
  final String? minSupportedVersion;
  final int? minSupportedBuild;
  final String? latestVersion;
  final int? latestBuild;
  final String? storeUrl;
  final String? message;

  const AppVersionPolicy({
    required this.platform,
    this.currentVersion,
    this.currentBuild,
    required this.forceUpdate,
    required this.comparisonMode,
    this.minSupportedVersion,
    this.minSupportedBuild,
    this.latestVersion,
    this.latestBuild,
    this.storeUrl,
    this.message,
  });

  factory AppVersionPolicy.fromJson(Map<String, dynamic> json) {
    return AppVersionPolicy(
      platform: (json['platform'] ?? 'android').toString(),
      currentVersion: json['current_version']?.toString(),
      currentBuild: _toInt(json['current_build']),
      forceUpdate: json['force_update'] == true,
      comparisonMode: (json['comparison_mode'] ?? 'version').toString(),
      minSupportedVersion: json['min_supported_version']?.toString(),
      minSupportedBuild: _toInt(json['min_supported_build']),
      latestVersion: json['latest_version']?.toString(),
      latestBuild: _toInt(json['latest_build']),
      storeUrl: json['store_url']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'current_version': currentVersion,
      'current_build': currentBuild,
      'force_update': forceUpdate,
      'comparison_mode': comparisonMode,
      'min_supported_version': minSupportedVersion,
      'min_supported_build': minSupportedBuild,
      'latest_version': latestVersion,
      'latest_build': latestBuild,
      'store_url': storeUrl,
      'message': message,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static AppVersionPolicy? fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppVersionPolicy.fromJson(decoded);
      }
      if (decoded is Map) {
        return AppVersionPolicy.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {}

    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
