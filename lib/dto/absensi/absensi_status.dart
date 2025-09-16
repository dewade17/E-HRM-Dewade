class AbsensiStatusDto {
  final String mode; // "checkin" | "checkout" | "done"
  final String today;
  final String? jamMasuk;
  final String? jamPulang;

  AbsensiStatusDto({
    required this.mode,
    required this.today,
    this.jamMasuk,
    this.jamPulang,
  });

  factory AbsensiStatusDto.fromJson(Map<String, dynamic> json) {
    return AbsensiStatusDto(
      mode: json['mode'] ?? 'checkin',
      today: (json['today'] ?? '').toString(),
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
    );
  }
}
