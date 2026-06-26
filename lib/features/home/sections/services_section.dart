import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/features/services/services_catalog.dart';
import 'package:utilityhub/features/services/services_manager.dart';
import '../widgets/home_service_card.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  bool editMode = false;

  // Only first 7 editable
  List<ServiceItem> editable = [];

  // Fixed More card
  final ServiceItem moreCard = const ServiceItem(
    title: "More",
    icon: Icons.apps,
    route: "/services",
  );

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    editable = await ServicesManager.load(userId: userId);

    // Ensure max 7
    if (editable.length > 7) {
      editable = editable.take(7).toList();
    }

    setState(() {});
  }

  Future<void> _save() async {
    await ServicesManager.save(editable, userId: userId);
  }

  void _addService() async {
    final unused = ServicesCatalog.all.where(
      (s) => !editable.any((x) => x.title == s.title),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1115),
      builder: (_) {
        return ListView(
          children: unused.map((s) {
            return ListTile(
              title: Text(s.title, style: const TextStyle(color: Colors.white)),
              leading: Icon(s.icon, color: Colors.white),
              onTap: () {
                if (editable.length < 7) {
                  setState(() => editable.add(s));
                  _save();
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (editable.isEmpty) return const SizedBox();

    // Final list = 7 editable + 1 More card
    final List<ServiceItem> finalList = [...editable, moreCard];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Services",
              style: TextStyle(
                fontSize: 11.50,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E7EB),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => editMode = !editMode),
              child: Text(
                editMode ? "Done" : "Edit",
                style: const TextStyle(
                  fontSize: 11.50,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD66B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ⭐ FIXED 4×2 GRID — PERFECT UNIFORM CARDS
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              finalList.length + (editMode && editable.length < 7 ? 1 : 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05, // ⭐ PERFECT UNIFORM CARD SIZE
          ),
          itemBuilder: (context, index) {
            // Add button slot
            if (editMode && editable.length < 7 && index == editable.length) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onPressed: _addService,
                ),
              );
            }

            // More card slot
            if (index == 7) {
              return HomeServiceCard(
                title: moreCard.title,
                icon: moreCard.icon,
                route: moreCard.route,
                userId: userId,
              );
            }

            // Editable cards
            final item = editable[index];

            return Stack(
              children: [
                HomeServiceCard(
                  title: item.title,
                  icon: item.icon,
                  route: item.route,
                  userId: userId,
                ),

                if (editMode)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => editable.removeAt(index));
                        _save();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
