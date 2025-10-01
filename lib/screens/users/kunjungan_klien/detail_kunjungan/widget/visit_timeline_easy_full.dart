// visit_timeline_easy_full.dart
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';

class VisitTimelineEasyFull extends StatelessWidget {
  const VisitTimelineEasyFull({
    super.key,
    // --- MULAI ---
    required this.startDateText, // contoh: "07 September 2025"
    required this.startTimeText, // contoh: "09:30 AM"
    required this.startAddress,
    // --- SELESAI ---
    required this.endDateText, // contoh: "07 September 2025"
    required this.endTimeText, // contoh: "11.32 AM"
    required this.endAddress,
    // Styling
    this.accent = const Color(0xFFE30613), // merah seperti mockup
    this.textColor = const Color(0xFF6A6F7D),
    this.labelGap = 12, // <<< jarak teks MULAI/SELESAI ke step
  });

  final String startDateText;
  final String startTimeText;
  final String startAddress;

  final String endDateText;
  final String endTimeText;
  final String endAddress;

  final Color accent;
  final Color textColor;

  /// Jarak antara teks label ("MULAI"/"SELESAI") dengan bulatan step
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF7F8FA);
    const labelDim = Color(0xFFB4BAC5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== LEFT: Vertical stepper (2 langkah)
        SizedBox(
          width: 50,
          child: EasyStepper(
            direction: Axis.vertical,
            activeStep: 1, // step terakhir aktif -> garis penuh merah
            enableStepTapping: false,
            showLoadingAnimation: false,
            stepRadius: 14, // lingkaran ~28px

            padding: const EdgeInsets.symmetric(vertical: 4),
            lineStyle: LineStyle(
              lineType: LineType.normal,
              defaultLineColor: accent,
              finishedLineColor: accent,
              lineThickness: 3,
              lineLength: 50,
            ),
            steps: [
              EasyStep(
                customStep: _circle(accent),
                // >>> label diberi top padding (labelGap)
                customTitle: _label('MULAI', color: textColor, gap: labelGap),
              ),
              EasyStep(
                customStep: _circle(accent),
                customTitle: _label('SELESAI', color: labelDim, gap: labelGap),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        // ===== RIGHT: dua blok konten (mulai & selesai)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineContent(
                dateText: startDateText,
                timeText: startTimeText,
                address: startAddress,
                textColor: textColor,
                cardBg: cardBg,
              ),
              const SizedBox(height: 24),
              _TimelineContent(
                dateText: endDateText,
                timeText: endTimeText,
                address: endAddress,
                textColor: textColor,
                cardBg: cardBg,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== helper kecil
  static Widget _label(
    String t, {
    required Color color,
    double gap = 12, // default top gap
  }) => Padding(
    // top = gap untuk nambah jarak dari bulatan step
    padding: EdgeInsets.only(top: gap, bottom: 6),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, letterSpacing: 0, color: color),
    ),
  );

  static Widget _circle(Color color) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: const Icon(Icons.check, size: 16, color: Colors.white),
  );
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({
    required this.dateText,
    required this.timeText,
    required this.address,
    required this.textColor,
    required this.cardBg,
  });

  final String dateText;
  final String timeText;
  final String address;
  final Color textColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris tanggal + jam (jam bold)
        RichText(
          text: TextSpan(
            style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            children: [
              TextSpan(text: '$dateText, '),
              TextSpan(
                text: timeText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Kartu alamat
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.location_pin, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
