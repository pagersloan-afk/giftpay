import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage.dart';

class DeviceTrust {
  static final _firestore = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  // ⭐ Generate or retrieve persistent deviceId
  static Future<String> getDeviceId() async {
    String? id = await SecureStorage.read("deviceId");

    if (id == null) {
      id = _uuid.v4();
      await SecureStorage.write("deviceId", id);
    }

    return id;
  }

  // ⭐ Get device name
  static Future<String> getDeviceName() async {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return "${android.manufacturer} ${android.model}";
    }

    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.utsname.machine ?? "iPhone";
    }

    return "Unknown Device";
  }

  // ⭐ Check if device is trusted
  static Future<bool> isTrustedDevice(String userId) async {
    final deviceId = await getDeviceId();
    final localToken = await SecureStorage.read("trustToken");

    if (localToken == null) return false;

    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("devices")
        .doc(deviceId)
        .get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    return data["trustToken"] == localToken && data["isTrusted"] == true;
  }

  // ⭐ Mark device as trusted
  static Future<void> markDeviceTrusted(String userId) async {
    final deviceId = await getDeviceId();
    final deviceName = await getDeviceName();
    final trustToken = _uuid.v4();

    await SecureStorage.write("trustToken", trustToken);
    await SecureStorage.write("userId", userId);

    await _firestore
        .collection("users")
        .doc(userId)
        .collection("devices")
        .doc(deviceId)
        .set({
          "deviceId": deviceId,
          "deviceName": deviceName,
          "deviceType": Platform.isAndroid
              ? "android"
              : Platform.isIOS
              ? "ios"
              : "other",
          "trustToken": trustToken,
          "isTrusted": true,
          "createdAt": FieldValue.serverTimestamp(),
          "lastLogin": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // ⭐ Clear trust on logout
  static Future<void> clearDeviceTrust() async {
    await SecureStorage.delete("trustToken");
    await SecureStorage.delete("userId");
  }
}
