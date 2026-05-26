import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';

class SavedMeterService {
  final String userId;

  SavedMeterService(this.userId);

  Stream<List<SavedMeter>> getSavedMeters() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("saved_meters")
        .orderBy("lastUsed", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => SavedMeter.fromMap(d.data())).toList(),
        );
  }
}
