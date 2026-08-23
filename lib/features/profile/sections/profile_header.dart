import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:utilityhub/config/api.dart';

class ProfileHeader extends StatefulWidget {
  final String? profileUrl;

  const ProfileHeader({super.key, this.profileUrl});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;
  String? _profileUrl;

  static const Color accent = Color(0xFF4FC3F7);
  static const Color darkSurface = Color(0xFF0F1115);

  /// Maximum profile-picture size accepted by the app/backend.
  static const int maxFileSize = 5 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _profileUrl = widget.profileUrl;
  }

  @override
  void didUpdateWidget(covariant ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profileUrl != widget.profileUrl) {
      setState(() {
        _profileUrl = widget.profileUrl;
      });
    }
  }

  // ================================================================
  // PROFILE PICTURE UPLOAD
  // ================================================================

  Future<void> _uploadProfilePicture() async {
    if (_uploading) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Your session has ended. Please sign in again.');
      return;
    }

    try {
      // ------------------------------------------------------------
      // 1. SELECT IMAGE
      // ------------------------------------------------------------

      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _uploading = true;
      });

      // ------------------------------------------------------------
      // 2. READ IMAGE
      // ------------------------------------------------------------

      final imageBytes = await picked.readAsBytes();

      if (imageBytes.isEmpty) {
        throw const ProfileUploadException(
          'The selected image is empty or could not be read.',
        );
      }

      // ------------------------------------------------------------
      // 3. CHECK 5 MB LIMIT BEFORE CONTACTING BACKEND
      // ------------------------------------------------------------

      if (imageBytes.length > maxFileSize) {
        throw const ProfileUploadException(
          'The selected image is too large. Maximum size is 5 MB.',
        );
      }

      // ------------------------------------------------------------
      // 4. VALIDATE IMAGE FORMAT
      // ------------------------------------------------------------

      final extension = _getExtension(picked.name);

      if (!_isSupportedExtension(extension)) {
        throw const ProfileUploadException(
          'Invalid image format. Please select a JPG, PNG, or WebP image.',
        );
      }

      final contentType = _contentType(extension);

      // ------------------------------------------------------------
      // 5. GET FIREBASE ID TOKEN
      //
      // Firebase Auth remains the ONLY authentication system.
      //
      // The UID is NOT trusted from the Flutter request.
      // The backend verifies this token and obtains the UID itself.
      // ------------------------------------------------------------

      final idToken = await user.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        throw const ProfileUploadException(
          'Unable to verify your Firebase session. Please sign in again.',
        );
      }

      // ------------------------------------------------------------
      // 6. BUILD BACKEND URL
      // ------------------------------------------------------------

      final baseUrl = ApiConfig.baseUrl;

      final uri = Uri.parse('$baseUrl/api/profile/upload-picture');

      // ------------------------------------------------------------
      // 7. MULTIPART REQUEST
      //
      // Flutter sends:
      //
      // Authorization: Bearer FIREBASE_ID_TOKEN
      //
      // image: selected image
      //
      // Backend verifies Firebase token before touching Supabase.
      // ------------------------------------------------------------

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'profile.$extension',
          contentType: _parseMediaType(contentType),
        ),
      );

      // ------------------------------------------------------------
      // 8. SEND TO BACKEND
      // ------------------------------------------------------------

      http.StreamedResponse streamedResponse;

      try {
        streamedResponse = await request.send();
      } on Exception {
        throw const ProfileUploadException(
          'Unable to reach the profile upload service. '
          'Please check your internet connection and try again.',
        );
      }

      final responseBody = await streamedResponse.stream.bytesToString();

      // ------------------------------------------------------------
      // 9. HANDLE HTTP ERRORS
      // ------------------------------------------------------------

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw _parseBackendError(streamedResponse.statusCode, responseBody);
      }

      // ------------------------------------------------------------
      // 10. PARSE SUCCESS RESPONSE
      // ------------------------------------------------------------

      final decoded = _decodeResponse(responseBody);

      final returnedProfileUrl = _extractProfileUrl(decoded);

      if (returnedProfileUrl == null || returnedProfileUrl.trim().isEmpty) {
        throw const ProfileUploadException(
          'The upload completed, but the server did not return '
          'a profile image URL.',
        );
      }

      // ------------------------------------------------------------
      // 11. UPDATE UI
      // ------------------------------------------------------------

      if (!mounted) return;

      setState(() {
        _profileUrl = returnedProfileUrl;
        _uploading = false;
      });

      _showMessage('Profile picture updated successfully.');
    } on ProfileUploadException catch (e) {
      if (!mounted) return;

      setState(() {
        _uploading = false;
      });

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploading = false;
      });

      _showMessage('Unable to update profile picture: ${_cleanError(e)}');
    }
  }

  // ================================================================
  // FILE VALIDATION
  // ================================================================

  String _getExtension(String filename) {
    final cleanName = filename.trim().toLowerCase();

    final dot = cleanName.lastIndexOf('.');

    if (dot == -1 || dot == cleanName.length - 1) {
      return 'jpg';
    }

    final extension = cleanName.substring(dot + 1);

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpg';

      case 'png':
        return 'png';

      case 'webp':
        return 'webp';

      default:
        return extension;
    }
  }

  bool _isSupportedExtension(String extension) {
    return extension == 'jpg' || extension == 'png' || extension == 'webp';
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  http.MediaType _parseMediaType(String contentType) {
    final parts = contentType.split('/');

    if (parts.length != 2) {
      return http.MediaType('image', 'jpeg');
    }

    return http.MediaType(parts[0], parts[1]);
  }

  // ================================================================
  // BACKEND RESPONSE HANDLING
  // ================================================================

  dynamic _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String? _extractProfileUrl(dynamic decoded) {
    if (decoded is! Map) {
      return null;
    }

    final directUrl = decoded['profileUrl'];

    if (directUrl is String && directUrl.trim().isNotEmpty) {
      return directUrl;
    }

    final data = decoded['data'];

    if (data is Map) {
      final dataUrl = data['profileUrl'];

      if (dataUrl is String && dataUrl.trim().isNotEmpty) {
        return dataUrl;
      }
    }

    return null;
  }

  ProfileUploadException _parseBackendError(int statusCode, String body) {
    dynamic decoded;

    try {
      decoded = jsonDecode(body);
    } catch (_) {
      decoded = null;
    }

    String? serverMessage;

    if (decoded is Map) {
      final message = decoded['message'];

      if (message is String && message.trim().isNotEmpty) {
        serverMessage = message;
      }

      final error = decoded['error'];

      if (serverMessage == null && error is String && error.trim().isNotEmpty) {
        serverMessage = error;
      }
    }

    switch (statusCode) {
      case 400:
        return ProfileUploadException(
          serverMessage ??
              'Invalid profile picture. Please select a valid JPG, PNG, or WebP image.',
        );

      case 401:
        return const ProfileUploadException(
          'Your Firebase session has expired. Please sign in again.',
        );

      case 403:
        return ProfileUploadException(
          serverMessage ??
              'You are not authorized to upload a profile picture.',
        );

      case 404:
        return const ProfileUploadException(
          'The profile upload service could not be found.',
        );

      case 413:
        return const ProfileUploadException(
          'The selected image is too large. Maximum size is 5 MB.',
        );

      case 415:
        return const ProfileUploadException(
          'Invalid image format. Please select a JPG, PNG, or WebP image.',
        );

      case 422:
        return ProfileUploadException(
          serverMessage ?? 'The selected image could not be processed.',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ProfileUploadException(
          serverMessage ??
              'The profile upload service is temporarily unavailable. '
                  'Please try again.',
        );

      default:
        if (serverMessage != null) {
          return ProfileUploadException(serverMessage);
        }

        return ProfileUploadException(
          'Profile picture upload failed. '
          'Server returned HTTP $statusCode.',
        );
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection refused') ||
        message.contains('Connection reset')) {
      return 'Unable to reach the server. '
          'Please check your internet connection and try again.';
    }

    if (message.contains('TimeoutException')) {
      return 'The upload timed out. Please try again.';
    }

    return message.replaceFirst('Exception: ', '');
  }

  // ================================================================
  // UI MESSAGE
  // ================================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ================================================================
  // UI
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _profileUrl != null && _profileUrl!.trim().isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: _uploadProfilePicture,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ------------------------------------------------------
              // Outer luxury glow
              // ------------------------------------------------------
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent.withOpacity(0.22), Colors.transparent],
                    radius: 0.72,
                  ),
                ),
              ),

              // ------------------------------------------------------
              // Avatar ring
              // ------------------------------------------------------
              Container(
                width: 94,
                height: 94,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF75A1FF),
                      Color(0xFF4FC3F7),
                      Color(0xFF273D68),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.18),
                      blurRadius: 26,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: darkSurface,
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color(0xFF171A20),
                    backgroundImage: hasPhoto
                        ? NetworkImage(_profileUrl!)
                        : null,
                    child: !hasPhoto
                        ? const Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                ),
              ),

              // ------------------------------------------------------
              // Upload indicator
              // ------------------------------------------------------
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF12151A),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: _uploading
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Text(
          _uploading
              ? 'Uploading your profile picture...'
              : hasPhoto
              ? 'Tap your photo to change it'
              : 'Add a profile picture',
          style: TextStyle(
            color: Colors.white.withOpacity(0.52),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 22),
      ],
    );
  }
}

// ================================================================
// UPLOAD EXCEPTION
// ================================================================

class ProfileUploadException implements Exception {
  final String message;

  const ProfileUploadException(this.message);

  @override
  String toString() => message;
}
