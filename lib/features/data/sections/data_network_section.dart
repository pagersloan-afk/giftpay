import 'package:flutter/material.dart';

class DataNetworkSection extends StatelessWidget {
  final String selectedNetworkCode;
  final Map<String, String> networkNames;
  final ValueChanged<String?> onChanged;

  const DataNetworkSection({
    super.key,
    required this.selectedNetworkCode,
    required this.networkNames,
    required this.onChanged,
  });

  String _logoForNetwork(String name) {
    final normalized = name.toLowerCase();

    if (normalized.contains("mtn")) {
      return "assets/networks/mtn.png";
    }

    if (normalized.contains("glo")) {
      return "assets/networks/glo.jpg";
    }

    if (normalized.contains("airtel")) {
      return "assets/networks/airtel.png";
    }

    if (normalized.contains("9mobile") ||
        normalized.contains("9 mobile") ||
        normalized.contains("etisalat")) {
      return "assets/networks/9mobile.png";
    }

    return "";
  }

  Color _themeColorForNetwork(String name) {
    final normalized = name.toLowerCase();

    if (normalized.contains("mtn")) {
      return const Color(0xFFFFCC00);
    }

    if (normalized.contains("glo")) {
      return const Color(0xFF00A859);
    }

    if (normalized.contains("airtel")) {
      return const Color(0xFFE60000);
    }

    if (normalized.contains("9mobile") ||
        normalized.contains("9 mobile") ||
        normalized.contains("etisalat")) {
      return const Color(0xFF006E3A);
    }

    return Colors.blue;
  }

  Widget _networkVisual(String name) {
    final logoPath = _logoForNetwork(name);
    final themeColor = _themeColorForNetwork(name);

    if (logoPath.isEmpty) {
      return Icon(
        Icons.sim_card,
        size: 24,
        color: themeColor,
      );
    }

    return Image.asset(
      logoPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.sim_card,
          size: 24,
          color: themeColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        networkNames.containsKey(selectedNetworkCode)
            ? selectedNetworkCode
            : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF1F2937),

      decoration: const InputDecoration(
        labelText: "Network",
        border: OutlineInputBorder(),
      ),

      selectedItemBuilder: (context) {
        return networkNames.entries.map((entry) {
          return Row(
            children: [
              _networkVisual(entry.value),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          );
        }).toList();
      },

      items: networkNames.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              _networkVisual(entry.value),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),

      onChanged:
          networkNames.isEmpty
              ? null
              : onChanged,
    );
  }
}
