import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/kyc_detail_modal.dart';

class KycAdminPage extends StatelessWidget {
  const KycAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('KYC Verification', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users')
                  .where('kycStatus', isNotEqualTo: 'unverified').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Unable to load KYC submissions: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data?.docs ?? [];
                if (users.isEmpty) return const Center(child: Text('No KYC submissions yet'));
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data();
                    final status = (data['kycStatus'] ?? 'unknown').toString();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => showDialog(context: context, builder: (_) => KycDetailModal(data: data, userId: doc.id)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(data['name']?.toString() ?? 'Unknown User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(data['email']?.toString() ?? ''),
                            const SizedBox(height: 10),
                            Text('UID: ${doc.id}'),
                            Text('NIN/BVN: ${data['nin'] ?? '-'}'),
                            Text('Address: ${data['address'] ?? '-'}'),
                            Text('DOB: ${data['dob'] ?? '-'}'),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'verified' ? Colors.green.shade100 : status == 'pending' ? Colors.orange.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(status.toUpperCase(), style: TextStyle(
                                color: status == 'verified' ? Colors.green : status == 'pending' ? Colors.orange.shade800 : Colors.red,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                            const SizedBox(height: 16),
                            Text('Tap to preview uploaded documents', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
