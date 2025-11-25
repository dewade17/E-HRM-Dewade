import 'dart:io';
import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

enum _PickSource { camera, gallery, document }

class FilePickerFieldWidget extends StatelessWidget {
  const FilePickerFieldWidget({
    super.key,
    required this.label,
    this.file,
    this.fileUrl,
    required this.onFileChanged,
    this.prefixIcon = Icons.camera_alt_outlined,
    this.buttonText = 'Unggah Bukti',
    this.isRequired = false,
    this.validator,
    this.autovalidateMode,
    this.width = 350,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.allowedExtensions,
  });

  final String label;
  final File? file;
  final String? fileUrl;
  final ValueChanged<File?> onFileChanged;
  final IconData? prefixIcon;
  final String buttonText;
  final bool isRequired;
  final String? Function(File?)? validator;
  final AutovalidateMode? autovalidateMode;
  final double? width;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<String>? allowedExtensions;

  Future<void> _pickFile(
    BuildContext context,
    FormFieldState<File> state,
  ) async {
    final _PickSource? source = await showModalBottomSheet<_PickSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(ctx).pop(_PickSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(ctx).pop(_PickSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Dokumen (PDF/DOC)'),
              onTap: () => Navigator.of(ctx).pop(_PickSource.document),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    String? path;
    try {
      if (source == _PickSource.camera || source == _PickSource.gallery) {
        final XFile? xFile = await ImagePicker().pickImage(
          source: source == _PickSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          imageQuality: 85,
        );
        if (xFile != null) path = xFile.path;
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions:
              allowedExtensions ?? ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );
        if (result != null && result.files.single.path != null) {
          path = result.files.single.path;
        }
      }

      if (path == null) return;

      final File file = File(path);
      onFileChanged(file);
      state.didChange(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil file: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _clearFile(FormFieldState<File> state) {
    onFileChanged(null);
    state.didChange(null);
  }

  bool _isImageFile(String? path) {
    if (path == null) return false;
    final ext = p.extension(path).toLowerCase();
    return ext == '.png' ||
        ext == '.jpg' ||
        ext == '.jpeg' ||
        ext == '.heic' ||
        ext == '.webp';
  }

  bool _isImageUrl(String? url) {
    if (url == null) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDefaultColor,
      ),
    );

    return SizedBox(
      width: width,
      child: FormField<File>(
        validator:
            validator ??
            (value) {
              if (isRequired &&
                  value == null &&
                  (fileUrl == null || fileUrl!.isEmpty)) {
                return '$label tidak boleh kosong';
              }
              return null;
            },
        autovalidateMode: autovalidateMode,
        initialValue: file,
        builder: (FormFieldState<File> state) {
          final localFile = state.value;
          final bool hasContent =
              localFile != null || (fileUrl != null && fileUrl!.isNotEmpty);

          final bool showImagePreview = localFile != null
              ? _isImageFile(localFile.path)
              : _isImageUrl(fileUrl);

          final Color effectiveBorderColor = state.hasError
              ? AppColors.errorColor
              : (borderColor ?? AppColors.textDefaultColor);
          final Color effectiveBackgroundColor =
              backgroundColor ?? AppColors.textColor;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: '* ',
                        style: baseLabelStyle.copyWith(
                          color: AppColors.errorColor,
                        ),
                      ),
                    TextSpan(text: label, style: baseLabelStyle),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (!hasContent)
                InkWell(
                  onTap: () => _pickFile(context, state),
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: effectiveBackgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: effectiveBorderColor,
                        width: borderWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null)
                          Icon(prefixIcon, color: AppColors.secondTextColor),
                        if (prefixIcon != null) const SizedBox(width: 10),
                        Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey.shade100,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: localFile != null
                          ? (showImagePreview
                                ? Image.file(
                                    localFile,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        _buildDocPlaceholder(
                                          'Gambar Rusak',
                                          Icons.broken_image,
                                        ),
                                  )
                                : _buildDocPlaceholder(
                                    p.basename(localFile.path),
                                    Icons.insert_drive_file,
                                  ))
                          : (showImagePreview
                                ? Image.network(
                                    fileUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildDocPlaceholder(
                                              'Gagal memuat gambar',
                                              Icons.broken_image,
                                            ),
                                  )
                                : _buildDocPlaceholder(
                                    'Dokumen Terlampir',
                                    Icons.description,
                                  )),
                    ),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (localFile != null) {
                              _clearFile(state);
                            } else {
                              _pickFile(context, state);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              localFile != null ? Icons.close : Icons.edit,
                              color: AppColors.secondaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocPlaceholder(String fileName, IconData icon) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 56),
              const SizedBox(height: 12),
              Text(
                fileName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
