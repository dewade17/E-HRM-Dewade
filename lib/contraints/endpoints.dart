class Endpoints {
  static const String baseURL = "https://7qdb4npf-3000.asse.devtunnels.ms/api";
  static const String faceBaseURL = "https://7qdb4npf-8000.asse.devtunnels.ms";

  //auth
  static const String login = "$baseURL/mobile/auth/login";
  static const String getdataprivate = "$baseURL/mobile/auth/getdataprivate";

  //reset-password&&get-token
  static const String resetRequestToken =
      "$baseURL/mobile/auth/reset-password/request-token";
  static const String resetConfirm = "$baseURL/mobile/auth/reset-password";

  //location
  static const String location = "$baseURL/admin/location";

  //departements
  static const String departements = "$baseURL/mobile/departements";

  //getuser
  static const String users = "$baseURL/mobile/users";

  //get-approvers
  static const String getApprovers = "$baseURL/admin/approvers";

  //get-agendakerja
  static const String agendaKerja = "$baseURL/mobile/agenda-kerja";
  static const String agendaKerjaCrud = "$baseURL/agenda-kerja";
  static String agendaKerjaUser(String userId) => "$agendaKerja/user/$userId";
  static String agendaKerjaDetail(String id) => "$agendaKerjaCrud/$id";

  //get-agenda
  static const String agenda = "$baseURL/mobile/agenda";
  //detail-agenda
  static String agendaDetail(String id) => "$agenda/$id";

  //post-enrollface
  static const String faceEnroll = "$faceBaseURL/api/face/enroll";

  //post-verifyface
  static const String verifyFace = "$faceBaseURL/api/face/verify";

  //get-face
  static const String getFace = "$faceBaseURL/api/face";

  //absensi
  static String get absensiCheckin => "$faceBaseURL/api/absensi/checkin";
  static String get absensiCheckout => "$faceBaseURL/api/absensi/checkout";
  static String get absensiStatus => "/api/absensi/status";
}
