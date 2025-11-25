class Endpoints {
  static const String baseURL = "https://f54ldwpd-3000.asse.devtunnels.ms/api";
  static const String faceBaseURL =
      "https://face-recognition.onestepsolutionbali.com";

  //auth
  static const String login = "$baseURL/mobile/auth/login";
  static const String getdataprivate = "$baseURL/mobile/auth/getdataprivate";

  //reset-password&&get-token
  static const String resetRequestToken =
      "$baseURL/mobile/auth/reset-password/request-token";
  static const String resetConfirm = "$baseURL/mobile/auth/reset-password";

  //location
  static const String location = "$baseURL/admin/location";

  //pengajuan cuti
  static const String kategoriCuti = "$baseURL/admin/kategori-cuti";
  static const String pengajuanCuti = "$baseURL/mobile/pengajuan-cuti";
  static String konfigurasiCuti(String userId) =>
      "$baseURL/mobile/konfigurasi-cuti/$userId";

  // pengajuan izin tukar hari
  static const String pengajuanIzinTukarHari =
      "$baseURL/mobile/pengajuan-izin-tukar-hari";
  static String pengajuanIzinTukarHariDetail(String id) =>
      "$pengajuanIzinTukarHari/$id";
  static String pengajuanIzinTukarHariUpdate(String id) =>
      "$pengajuanIzinTukarHari/$id";
  static String pengajuanIzinTukarHariDelete(String id) =>
      "$pengajuanIzinTukarHari/$id";

  // kategori izin
  static const String kategoriIzinJam = "$baseURL/admin/kategori-izin-jam";
  static const String kategoriPengajuanSakit = "$baseURL/admin/kategori-sakit";
  static const String pengajuanIzinJam = "$baseURL/mobile/pengajuan-izin-jam";
  static String pengajuanIzinJamDetail(String id) => "$pengajuanIzinJam/$id";
  static const String pengajuanSakit = "$baseURL/mobile/pengajuan-izin-sakit";
  static String pengajuanSakitDetail(String id) => "$pengajuanSakit/$id";

  //departements
  static const String departements = "$baseURL/mobile/departements";

  //kunjungan
  static const String kategoriKunjungan = "$baseURL/admin/kategori-kunjungan";
  static String kategoriKunjunganDetail(String id) =>
      "$kategoriKunjunganDetail/$id";

  static const String kunjunganKlien = "$baseURL/mobile/kunjungan-klien";
  static String kunjunganKlienDetail(String id) => "$kunjunganKlien/$id";
  static String kunjunganKlienStartSubmit(String id) =>
      "$kunjunganKlien/$id/submit-start-kunjungan";
  static String kunjunganKlienEndSubmit(String id) =>
      "$kunjunganKlien/$id/submit-end-kunjungan";
  static String kunjunganKlienStatusBerlangsung(String id) =>
      "$kunjunganKlien/status-berlangsung";
  static String kunjunganKlienStatusDiproses(String id) =>
      "$kunjunganKlien/status-diproses";
  static String kunjunganKlienStatusSekesai(String id) =>
      "$kunjunganKlien/status-selesai";

  //getuser
  static const String users = "$baseURL/mobile/users";
  static const String tagHandOverUsers = "$baseURL/mobile/tag-users";

  //get-approvers
  static const String getApprovers = "$baseURL/admin/approvers";

  //get-agendakerja
  static const String agendaKerja = "$baseURL/mobile/agenda-kerja";
  static const String agendaKerjaCrud = "$baseURL/mobile/agenda-kerja";
  static String agendaKerjaUser(String userId) => "$agendaKerja/user/$userId";
  static String agendaKerjaDetail(String id) => "$agendaKerjaCrud/$id";

  //agenda (admin)
  static const String agenda = "$baseURL/admin/agenda";
  //detail-agenda
  static String agendaDetail(String id) => "$agenda/$id";

  // shift kerja
  static const String shiftKerja = "$baseURL/admin/shift-kerja";
  static String shiftKerjaRealtime(String id) =>
      "$shiftKerja/user/$id/realtime";

  //post-enrollface
  static const String faceEnroll = "$faceBaseURL/api/face/enroll";

  //post-verifyface
  static const String verifyFace = "$faceBaseURL/api/face/verify";

  //get-face
  static const String getFace = "$faceBaseURL/api/face";

  //absensi
  static String get absensiCheckin => "$faceBaseURL/api/absensi/checkin";
  static String get absensiCheckout => "$faceBaseURL/api/absensi/checkout";
  static String get absensiStatus => "$faceBaseURL/api/absensi/status";

  //istirahats
  static const String istirahatStart =
      "$faceBaseURL/api/absensi/istirahat/start";
  static const String istirahatEnd = "$faceBaseURL/api/absensi/istirahat/end";
  static const String istirahatStatus =
      "$faceBaseURL/api/absensi/istirahat/status";

  //notification
  static const String getNotifications = "$baseURL/notifications";
  static String markNotificationAsRead(String notificationId) =>
      "$baseURL/notifications/$notificationId";
  static const String markAllNotificationsAsRead =
      "$baseURL/notifications/mark-all-as-read";

  static const String mobileCalendar = "$baseURL/mobile/calendar";
}
