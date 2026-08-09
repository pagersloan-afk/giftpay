import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycStepIdUpload extends StatelessWidget {
  final XFile? idFront;
  final XFile? idBack;
  final List<String> rejectedDocs;

  final Future<XFile?> Function() pickImage;

  final VoidCallback onContinue;

  // ⭐ NEW CALLBACKS
  final void Function(XFile file) onFrontSelected;
  final void Function(XFile file) onBackSelected;

  const KycStepIdUpload({
    super.key,
    required this.idFront,
    required this.idBack,
    required this.rejectedDocs,
    required this.pickImage,
    required this.onContinue,
    required this.onFrontSelected,
    required this.onBackSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tile(
          label: "Upload ID Card (Front)",
          file: idFront,
          rejected: rejectedDocs.contains("idFront"),
          onTap: () async {
            final f = await pickImage();
            if (f != null) onFrontSelected(f); // ⭐ FIXED
          },
        ),

        _tile(
          label: "Upload ID Card (Back)",
          file: idBack,
          rejected: rejectedDocs.contains("idBack"),
          onTap: () async {
            final f = await pickImage();
            if (f != null) onBackSelected(f); // ⭐ FIXED
          },
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: idFront != null && idBack != null ? onContinue : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required String label,
    required XFile? file,
    required bool rejected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: rejected ? Colors.red : Colors.black26,
            width: rejected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: rejected ? Colors.red.shade50 : null,
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: rejected
                  ? Colors.red
                  : file == null
                  ? Colors.grey
                  : Colors.green,
            ),
            const SizedBox(width: 12),
            Text(
              rejected
                  ? "$label (Rejected)"
                  : file == null
                  ? label
                  : "$label (Uploaded)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: rejected
                    ? Colors.red
                    : file == null
                    ? Colors.black54
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
