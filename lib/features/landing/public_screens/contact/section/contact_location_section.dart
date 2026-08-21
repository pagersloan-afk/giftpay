import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:utilityhub/core/theme/giftpay_theme.dart';

class ContactLocationSection extends StatelessWidget {
  const ContactLocationSection({super.key});

  /*
   * Chidan / 6th Avenue, off SARS Road, Agbada Estate,
   * Port Harcourt, Rivers State.
   *
   * IMPORTANT:
   * These are intentionally kept in one place so the exact Chidan Hotel
   * pin can be substituted without changing the rest of this screen.
   *
   * SARS Road itself is publicly listed around:
   * 4.8931, 6.9735.
   *
   * Do not describe this as the exact hotel GPS coordinate until the
   * exact Chidan Hotel pin has been verified.
   */
  static const double _latitude = 4.8931;
  static const double _longitude = 6.9735;

  static const LatLng _officeLocation = LatLng(_latitude, _longitude);

  static const String _address =
      'Plot 12, 6th Avenue, off SARS Road, '
      'Agbada Estate, Port Harcourt, Rivers State, Nigeria';

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$_latitude,$_longitude',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 32,
        vertical: isMobile ? 28 : 42,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile ? _buildMobile(context) : _buildDesktop(context),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLocationDetails(context)),

        const SizedBox(width: 28),

        Expanded(child: _buildMap()),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLocationDetails(context),

        const SizedBox(height: 22),

        _buildMap(),
      ],
    );
  }

  Widget _buildLocationDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E8F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: GiftPayTheme.primaryBlue,
            size: 34,
          ),

          const SizedBox(height: 20),

          const Text(
            'Visit our office',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF142850),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Our office is located just a few buildings from Chidan Hotel '
            'on 6th Avenue, off SARS Road.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              height: 1.6,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.business_outlined,
                  color: GiftPayTheme.primaryBlue,
                  size: 22,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _address,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14,
                      height: 1.55,
                      color: Color(0xFF273D68),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions_outlined, size: 19),
              label: const Text(
                'Get Directions',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftPayTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      width: double.infinity,
      height: 420,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _officeLocation,
                initialZoom: 16.0,
                minZoom: 12.0,
                maxZoom: 19.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.utilityhub.app',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: _officeLocation,
                      width: 70,
                      height: 70,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GiftPayTheme.primaryBlue,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              left: 18,
              top: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 17,
                      color: GiftPayTheme.primaryBlue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GiftPay Office',
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF142850),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
