class DeviceInfo {
  String? deviceLabel;
  String? platform;
  String? osVersion;
  String? appVersion;
  String? deviceIdentifier;

  DeviceInfo({
    this.deviceLabel,
    this.platform,
    this.osVersion,
    this.appVersion,
    this.deviceIdentifier,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    deviceLabel: json['device_label'],
    platform: json['platform'],
    osVersion: json['os_version'],
    appVersion: json['app_version'],
    deviceIdentifier: json['device_identifier'],
  );

  Map<String, dynamic> toJson() => {
    if (deviceLabel != null) 'device_label': deviceLabel,
    if (platform != null) 'platform': platform,
    if (osVersion != null) 'os_version': osVersion,
    if (appVersion != null) 'app_version': appVersion,
    if (deviceIdentifier != null) 'device_identifier': deviceIdentifier,
  };

  /// Untuk memudahkan bikin FormData (multipart)
  Map<String, String> toFormFields() => {
    if ((deviceLabel ?? '').isNotEmpty) 'device_label': deviceLabel!,
    if ((platform ?? '').isNotEmpty) 'platform': platform!,
    if ((osVersion ?? '').isNotEmpty) 'os_version': osVersion!,
    if ((appVersion ?? '').isNotEmpty) 'app_version': appVersion!,
    if ((deviceIdentifier ?? '').isNotEmpty)
      'device_identifier': deviceIdentifier!,
  };
}
