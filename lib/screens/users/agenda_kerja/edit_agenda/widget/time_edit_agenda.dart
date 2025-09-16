import 'package:flutter/material.dart';

class TimeEditAgenda extends StatefulWidget {
  const TimeEditAgenda({
    super.key,
    this.onChanged,
    this.initialStart,
    this.initialEnd,
  });

  final void Function(TimeOfDay? jamMulai, TimeOfDay? jamSelesai)? onChanged;
  final TimeOfDay? initialStart;
  final TimeOfDay? initialEnd;

  @override
  State<TimeEditAgenda> createState() => _TimeEditAgendaState();
}

class _TimeEditAgendaState extends State<TimeEditAgenda> {
  TimeOfDay? _start;
  TimeOfDay? _end;

  late final TextEditingController _startC = TextEditingController();
  late final TextEditingController _endC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setInitialValues(widget.initialStart, widget.initialEnd);
  }

  @override
  void didUpdateWidget(TimeEditAgenda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStart != widget.initialStart ||
        oldWidget.initialEnd != widget.initialEnd) {
      _setInitialValues(widget.initialStart, widget.initialEnd);
    }
  }

  void _setInitialValues(TimeOfDay? start, TimeOfDay? end) {
    _start = start;
    _end = end;
    _startC.text = _fmt(_start);
    _endC.text = _fmt(_end);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged?.call(_start, _end);
    });
  }

  @override
  void dispose() {
    _startC.dispose();
    _endC.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final init = isStart
        ? (_start ?? TimeOfDay.now())
        : (_end ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      helpText: isStart ? 'Pilih Jam Mulai' : 'Pilih Jam Selesai',
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
      _startC.text = _fmt(_start);
      _endC.text = _fmt(_end);
    });

    widget.onChanged?.call(_start, _end);
  }

  String _fmt(TimeOfDay? t) {
    if (t == null) return '';
    final l = MaterialLocalizations.of(context);
    return l.formatTimeOfDay(t, alwaysUse24HourFormat: true);
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    hintText: '-- : --',
    prefixIcon: const Icon(Icons.access_time),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 1.6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _startC,
            readOnly: true,
            onTap: () => _pickTime(isStart: true),
            decoration: _decoration('Jam Mulai'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _endC,
            readOnly: true,
            onTap: () => _pickTime(isStart: false),
            decoration: _decoration('Jam Selesai'),
          ),
        ),
      ],
    );
  }
}
