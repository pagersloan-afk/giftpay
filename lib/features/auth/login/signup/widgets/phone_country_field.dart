import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class PhoneCountryField extends StatelessWidget {
  final Country? selectedCountry;
  final TextEditingController phoneCtrl;
  final Function(Country) onSelect;

  const PhoneCountryField({
    super.key,
    required this.selectedCountry,
    required this.phoneCtrl,
    required this.onSelect,
  });

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: onSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => _pickCountry(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Text(
                  selectedCountry != null
                      ? '+${selectedCountry!.phoneCode}'
                      : '+',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
