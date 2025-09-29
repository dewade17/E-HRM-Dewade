import 'package:e_hrm/providers/absensi/absensi_provider.dart';
import 'package:e_hrm/providers/agenda/agenda_provider.dart';
import 'package:e_hrm/providers/agenda_kerja/agenda_kerja_provider.dart';
import 'package:e_hrm/providers/approvers/approvers_absensi_provider.dart';
import 'package:e_hrm/providers/kunjungan/kategori_kunjungan_provider.dart';
import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:e_hrm/providers/auth/reset_password_provider.dart';
import 'package:e_hrm/providers/departements/departements_provider.dart';
import 'package:e_hrm/providers/kunjungan/kunjungan_provider.dart';
import 'package:e_hrm/providers/location/location_provider.dart';
import 'package:e_hrm/providers/profile/profile_provider.dart';
import 'package:e_hrm/providers/shift_kerja/shift_kerja_realtime_provider.dart';
import 'package:e_hrm/screens/auth/login/login_screen.dart';
import 'package:e_hrm/screens/auth/reset_password/reset_password_screen.dart';
import 'package:e_hrm/screens/opening/opening_screen.dart';
import 'package:e_hrm/screens/users/profile/profile_screen.dart';
import 'package:e_hrm/screens/users/agenda_kerja/agenda_kerja_screen.dart';
import 'package:e_hrm/screens/users/home/home_screen.dart';
import 'package:e_hrm/screens/users/jam_isitirahat/jam_istirahat_screen.dart';
import 'package:e_hrm/screens/users/kunjungan_klien/kunjungan_klien_screen.dart';
import 'package:e_hrm/services/auth_wrapper.dart';
import 'package:e_hrm/utils/app_theme.dart';
import 'package:e_hrm/providers/face/face_enroll/face_enroll_provider.dart';
import 'package:e_hrm/screens/face/face_enroll_screen/face_enroll_screen.dart';
import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data locale (Indonesia)
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID'; // opsional, biar default Indonesia

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => DepartementProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AgendaKerjaProvider()),
        ChangeNotifierProvider(create: (_) => FaceEnrollProvider(ApiService())),
        ChangeNotifierProvider(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider(create: (_) => ApproversProvider()),
        ChangeNotifierProvider(create: (_) => KategoriKunjunganProvider()),
        ChangeNotifierProvider(create: (_) => ShiftKerjaRealtimeProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => KunjunganProvider()),
      ],
      child: MaterialApp(
        title: 'E-HRM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const OpeningScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/home-screen': (context) => AuthWrapper(child: HomeScreen()),
          '/profile-screen': (context) => AuthWrapper(child: ProfileScreen()),
          // Route for face enrollment. Pass the userId via RouteSettings arguments.
          '/face-enroll': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            // Expecting a String userId; if missing, fallback to empty string to avoid crash.
            final userId = (args is String) ? args : '';
            return AuthWrapper(child: FaceEnrollScreen(userId: userId));
          },
          '/agenda-kerja': (context) => AuthWrapper(child: AgendaKerjaScreen()),
          '/kunjungan-klien': (context) =>
              AuthWrapper(child: KunjunganKlienScreen()),
          '/jam-istirahat': (context) =>
              AuthWrapper(child: JamIstirahatScreen()),
        },
      ),
    );
  }
}
