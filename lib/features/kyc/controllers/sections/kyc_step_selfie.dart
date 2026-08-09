import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycStepSelfie extends StatelessWidget {
  final XFile? selfie;
  final bool submitting;
  final List<String> rejectedDocs;

  final Future<XFile?> Function() pickImage;

  final VoidCallback onSubmit;

  // ⭐ NEW CALLBACK
  final void Function(XFile file) onSelfieSelected;

  const KycStepSelfie({
    super.key,
    required this.selfie,
    required this.submitting,
    required this.rejectedDocs,
    required this.pickImage,
    required this.onSubmit,
    required this.onSelfieSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tile(
          label: "Upload Selfie",
          file: selfie,
          rejected: rejectedDocs.contains("selfie"),
          onTap: () async {
            final f = await pickImage();
            if (f != null) onSelfieSelected(f); // ⭐ FIXED
          },
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            child: submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit Verification"),
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
