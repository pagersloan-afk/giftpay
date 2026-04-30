import 'package:flutter/material.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_trade.dart';

class GiftCardTradeHistoryScreen extends StatelessWidget {
  const GiftCardTradeHistoryScreen({super.key});

  // Mock trades (replace with Firestore later)
  List<GiftCardTrade> get mockTrades => [
    GiftCardTrade(
      id: "1",
      brand: "Amazon",
      country: "USA",
      cardType: "Physical",
      amount: "100",
      rate: "750",
      valueInNaira: "75000",
      images: [],
      status: "pending",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    GiftCardTrade(
      id: "2",
      brand: "Steam",
      country: "Global",
      cardType: "E-code",
      amount: "50",
      rate: "700",
      valueInNaira: "35000",
      images: [],
      status: "reviewing",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GiftCardTrade(
      id: "3",
      brand: "Apple",
      country: "UK",
      cardType: "Physical",
      amount: "200",
      rate: "800",
      valueInNaira: "160000",
      images: [],
      status: "completed",
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "reviewing":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trades = mockTrades;

    return Scaffold(
      appBar: AppBar(title: const Text("Gift Card Trades")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trades.length,
        itemBuilder: (_, i) {
          final trade = trades[i];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TradeDetailsScreen(trade: trade),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Brand icon placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.card_giftcard, size: 28),
                  ),

                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trade.brand,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₦${trade.valueInNaira}",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${trade.createdAt}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(trade.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trade.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor(trade.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TradeDetailsScreen extends StatelessWidget {
  final GiftCardTrade trade;

  const TradeDetailsScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trade Details")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Brand: ${trade.brand}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Country: ${trade.country}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Card Type: ${trade.cardType}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: \$${trade.amount}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text("Rate: ₦${trade.rate}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Value in Naira: ₦${trade.valueInNaira}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${trade.status}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${trade.createdAt}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
