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

  Future<void> saveMeter(SavedMeter meter) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("saved_meters")
        .doc(meter.meterNumber) // use meter number as doc ID
        .set({
          "meterNumber": meter.meterNumber,
          "meterType": meter.meterType,
          "discoCode": meter.discoCode,
          "customerName": meter.customerName,
          "lastUsed": meter.lastUsed,
        }, SetOptions(merge: true));
  }
}
