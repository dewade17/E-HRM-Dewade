import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatatanAbsensiCheckin extends StatefulWidget {
  const CatatanAbsensiCheckin({
    super.key,
    this.onChanged,
    this.initialValues = const [],
  });

  final ValueChanged<List<String>>? onChanged;
  final List<String> initialValues;

  @override
  State<CatatanAbsensiCheckin> createState() => _CatatanAbsensiCheckinState();
}

class _CatatanAbsensiCheckinState extends State<CatatanAbsensiCheckin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    if (widget.initialValues.isNotEmpty) {
      for (final value in widget.initialValues) {
        _addController(text: value);
      }
    }
    if (_controllers.isEmpty) {
      _addController();
    }
  }

  @override
  void didUpdateWidget(covariant CatatanAbsensiCheckin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.initialValues, widget.initialValues)) {
      _replaceControllers(widget.initialValues);
    }
  }

  void _replaceControllers(List<String> values) {
    for (final controller in _controllers) {
      controller.removeListener(_notify);
      controller.dispose();
    }
    _controllers.clear();
    if (values.isEmpty) {
      _addController();
    } else {
      for (final value in values) {
        _addController(text: value);
      }
    }
    _notify();
    setState(() {});
  }

  void _addController({String text = ''}) {
    final controller = TextEditingController(text: text);
    controller.addListener(_notify);
    _controllers.add(controller);
  }

  void _removeController(int index) {
    if (_controllers.length == 1) {
      _controllers[index].clear();
      _notify();
      setState(() {});
      return;
    }
    final controller = _controllers.removeAt(index);
    controller.removeListener(_notify);
    controller.dispose();
    _notify();
    setState(() {});
  }

  void _notify() {
    if (widget.onChanged == null) return;
    final values = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    widget.onChanged!(values);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_notify);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Catatan",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDefaultColor,
                ),
              ),
            ),
          ),
        ),
        Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ..._controllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _controllers.length - 1 ? 0 : 12,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: controller,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Tulis catatan…',
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                alignLabelWithHint: true,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Icon(Icons.comment),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close_outlined),
                                  onPressed: () => _removeController(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _addController();
                          });
                        },
                        child: SizedBox(
                          width: 150,
                          height: 50,
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle),
                                const SizedBox(width: 10),
                                Text(
                                  "Catatan",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDefaultColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
