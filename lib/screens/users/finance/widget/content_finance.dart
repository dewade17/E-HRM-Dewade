import 'package:e_hrm/contraints/colors.dart';
import 'package:e_hrm/screens/users/finance/payment/add_payment/payment_screen.dart';
import 'package:e_hrm/screens/users/finance/payment/riwayat_payment/riwayat_payment_screen.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/add_pocket_money/pocket_money_screen.dart';
import 'package:e_hrm/screens/users/finance/pocket_money/riwayat_pocket_money/riwayat_pocket_money_screen.dart';
import 'package:e_hrm/screens/users/finance/reimburse/add_reimburse/reimburse_screen.dart';
import 'package:e_hrm/screens/users/finance/reimburse/riwayat_reimburse/riwayat_reimburse_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentFinance extends StatefulWidget {
  const ContentFinance({super.key});

  @override
  State<ContentFinance> createState() => _ContentFinanceState();
}

class _ContentFinanceState extends State<ContentFinance> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FinanceCard(
            type: "reimburse",
            title: "Reimburse !",
            subtitle:
                "Semua pengeluaran kerja bisa balik, \ncukup ajukan reimburse disini!",
            imagePath: 'lib/assets/image/finance/reimbursex4.png',
            button1Text: "Ajukan",
            onButton1Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReimburseScreen()),
              );
            },
            button2Text: "Riwayat",
            onButton2Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatReimburseScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          FinanceCard(
            type: "pocket",
            title: "Pocket Money !",
            subtitle:
                "Butuh tambahan buat jalanin \nkerjaan? Klaim pocket money easy banget, tinggal klik! ",
            imagePath: 'lib/assets/image/finance/trypocketx4.png',
            button1Text: "Klaim",
            onButton1Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PocketMoneyScreen()),
              );
            },
            button2Text: "Riwayat",
            onButton2Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatPocketMoneyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          FinanceCard(
            type: "payment",
            title: "Payment !",
            subtitle:
                "Pengajuan pembayaran kerja jadi lebih mudah. Request payment dan cek riwayat transaksi di sini!",
            imagePath: 'lib/assets/image/finance/trypaymentx4.png',
            button1Text: "Request",
            onButton1Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
            },
            button2Text: "Riwayat",
            onButton2Pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RiwayatPaymentScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FinanceCard extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String imagePath;
  final String button1Text;
  final VoidCallback onButton1Pressed;
  final String button2Text;
  final VoidCallback onButton2Pressed;

  const FinanceCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.button1Text,
    required this.onButton1Pressed,
    required this.button2Text,
    required this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(13)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.menuColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.menuColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: onButton1Pressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: AppColors.secondaryColor,
                      ),
                      child: Text(button1Text),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onButton2Pressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: AppColors.secondaryColor,
                      ),
                      child: Text(button2Text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          top: -25.6,
          right: -3.8,
          child: Image.asset(imagePath, height: 140, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
