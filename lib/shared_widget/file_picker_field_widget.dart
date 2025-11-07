// lib/shared_widget/file_picker_field_widget.dart
import 'dart:io';
import 'package:e_hrm/contraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // <-- Pakai file_picker
import 'package:image_picker/image_picker.dart'; // <-- Pakai image_picker
import 'package:path/path.dart' as p; // Untuk cek ekstensi & nama file

// Enum untuk membedakan sumber pilihan
enum _PickSource { camera, gallery, document }

/// Widget input yang dapat digunakan kembali untuk memilih file (gambar atau dokumen).
/// Tampil sebagai tombol "Unggah" dan menunjukkan preview file di bawahnya.
class FilePickerFieldWidget extends StatelessWidget {
  const FilePickerFieldWidget({
    super.key,
    required this.label,
    this.file, // Menerima File?
    required this.onFileChanged, // Mengembalikan File?
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
  });

  /// Teks label di atas field.
  final String label;

  /// File yang sedang dipilih (dikelola oleh state parent).
  final File? file; // <-- Tipe file diubah ke File

  /// Callback yang dipanggil saat file berubah (mengirim File asli atau null).
  final ValueChanged<File?> onFileChanged;

  /// Ikon di sebelah kiri teks tombol.
  final IconData? prefixIcon;

  /// Teks pada tombol.
  final String buttonText;

  /// Menandakan apakah field ini wajib diisi.
  final bool isRequired;

  /// Validator untuk File.
  final String? Function(File?)? validator;

  /// Mode autovalidasi untuk FormField.
  final AutovalidateMode? autovalidateMode;

  /// Properti UI
  final double? width;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  // --- Logika untuk memilih file ---
  Future<void> _pickFile(
    BuildContext context,
    FormFieldState<File> state,
  ) async {
    // 1. Tampilkan modal untuk memilih sumber
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

    if (source == null) return; // Batal memilih

    String? path;
    try {
      if (source == _PickSource.camera || source == _PickSource.gallery) {
        // 2. Gunakan IMAGE_PICKER
        final XFile? xFile = await ImagePicker().pickImage(
          source: source == _PickSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          imageQuality: 85,
        );
        if (xFile != null) {
          path = xFile.path;
        }
      } else {
        // 3. Gunakan FILE_PICKER
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );
        if (result != null && result.files.single.path != null) {
          path = result.files.single.path;
        }
      }

      if (path == null) return; // Batal memilih file

      final File file = File(path);
      onFileChanged(file); // Kirim file ke parent
      state.didChange(file); // Update state FormField
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil file: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  // --- Logika untuk menghapus file ---
  void _clearFile(FormFieldState<File> state) {
    onFileChanged(null); // Kirim null ke parent
    state.didChange(null); // Update state FormField
  }

  // --- Helper untuk cek apakah file gambar ---
  bool _isImageFile(String? path) {
    if (path == null) return false;
    final ext = p.extension(path).toLowerCase();
    return ext == '.png' ||
        ext == '.jpg' ||
        ext == '.jpeg' ||
        ext == '.heic' ||
        ext == '.webp';
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
        // Validasi kini berdasarkan objek File
        validator:
            validator ??
            (value) {
              if (isRequired && value == null) {
                return '$label tidak boleh kosong';
              }
              return null;
            },
        autovalidateMode: autovalidateMode,
        initialValue: file,
        builder: (FormFieldState<File> state) {
          final bool hasFile = state.value != null;
          final file = state.value;
          final bool isImage = _isImageFile(file?.path);

          final Color effectiveBorderColor = state.hasError
              ? AppColors.errorColor
              : (borderColor ?? AppColors.textDefaultColor);
          final Color effectiveBackgroundColor =
              backgroundColor ?? AppColors.textColor;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Label
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

              // 2. Teks Error (jika ada, tampil di bawah label)
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

              // 3. Tombol "Unggah Bukti" (HANYA tampil jika *tidak ada* file)
              if (!hasFile)
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
                ),

              // 4. Preview File (HANYA tampil jika *ada* file)
              if (hasFile && file != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Kotak Preview (Gambar atau Dokumen)
                    Container(
                      width: double.infinity,
                      // Tentukan tinggi atau rasio aspek
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias, // Penting untuk Image
                      child: isImage
                          // --- PREVIEW GAMBAR ---
                          ? Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  _buildDocPlaceholder(
                                    'Error: Gambar rusak',
                                    Icons.broken_image,
                                  ),
                            )
                          // --- PREVIEW DOKUMEN ---
                          : _buildDocPlaceholder(
                              p.basename(file.path), // Tampilkan nama file
                              Icons.description_outlined,
                            ),
                    ),
                    // Tombol Hapus (X)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _clearFile(state),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.errorColor,
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

  /// Helper untuk placeholder file non-gambar (PDF, DOCX, dll.)
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
