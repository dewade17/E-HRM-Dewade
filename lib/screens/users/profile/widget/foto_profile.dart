import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_hrm/contraints/colors.dart';

class FotoProfile extends StatefulWidget {
  final String? imageUrl;
  final ImageProvider? initialImage;
  final void Function(File? file)? onPicked;
  final VoidCallback? onRemove;
  final double radius;
  final bool enabled;

  const FotoProfile({
    super.key,
    this.imageUrl,
    this.initialImage,
    this.onPicked,
    this.onRemove,
    this.radius = 60,
    this.enabled = true,
  });

  @override
  State<FotoProfile> createState() => _FotoProfileState();
}

class _FotoProfileState extends State<FotoProfile> {
  final ImagePicker _picker = ImagePicker();
  File? _localFile;
  ImageProvider? _netImage;
  Object? _lastImageError;

  // -- helper: set image dari URL dg sanitasi + precache
  void _setNetFromUrl(String? raw) {
    final url = (raw ?? '').trim();
    if (url.isEmpty) {
      // debugPrint('FotoProfile: empty url');
      setState(() => _netImage = null);
      return;
    }
    final img = NetworkImage(url);
    // pre-load untuk dapat error detail kalau gagal
    precacheImage(
      img,
      context,
      onError: (e, st) {
        // debugPrint('FotoProfile.precache error: $e');
        if (mounted) {
          setState(() {
            _lastImageError = e;
            _netImage = null;
          });
        }
      },
    );
    // debugPrint('FotoProfile: using url=$url');
    setState(() {
      _lastImageError = null;
      _netImage = img;
    });
  }

  @override
  void initState() {
    super.initState();
    // debugPrint('FotoProfile.init imageUrl=${widget.imageUrl}');
    if (widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty) {
      // tunggu frame agar context siap untuk precacheImage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setNetFromUrl(widget.imageUrl);
      });
    } else {
      _netImage = widget.initialImage;
    }
  }

  @override
  void didUpdateWidget(covariant FotoProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      // debugPrint(
      //   'FotoProfile.update old=${oldWidget.imageUrl} new=${widget.imageUrl}',
      // );
      _setNetFromUrl(widget.imageUrl);
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      if (x == null) return;
      final file = File(x.path);
      setState(() => _localFile = file);
      widget.onPicked?.call(file);
    } catch (_) {
      /* ignore */
    }
  }

  void _showPicker() {
    if (!widget.enabled) return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Photo Library'),
                onTap: () {
                  _pick(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Camera'),
                onTap: () {
                  _pick(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_localFile != null ||
                  (widget.imageUrl?.trim().isNotEmpty ?? false) ||
                  widget.initialImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto'),
                  onTap: () {
                    setState(() {
                      _localFile = null;
                      _netImage = null;
                      _lastImageError = null;
                    });
                    widget.onPicked?.call(null);
                    widget.onRemove?.call();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    ImageProvider? provider;
    if (_localFile != null) {
      provider = FileImage(_localFile!);
    } else {
      provider = _netImage;
    }

    final cameraTap = widget.enabled ? _showPicker : null;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar (klik untuk pilih foto)
          Positioned.fill(
            child: GestureDetector(
              onTap: cameraTap,
              child: CircleAvatar(
                radius: widget.radius,
                backgroundColor: Colors.white,
                backgroundImage: provider,
                onBackgroundImageError: provider != null
                    ? (exception, stackTrace) {
                        // debugPrint('FotoProfile.imageError: $exception');
                        if (_lastImageError != exception) {
                          setState(() {
                            _lastImageError = exception;
                            _netImage = null; // fallback ke icon person
                          });
                        }
                      }
                    : null,
                child: provider == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.secondaryColor,
                      )
                    : null,
              ),
            ),
          ),
          // Badge kamera di kanan-bawah
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: cameraTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
