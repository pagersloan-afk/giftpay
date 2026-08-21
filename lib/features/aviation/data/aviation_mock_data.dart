const List<Map<String, dynamic>> aviationMockOffers = [
  {
    "id": "GP-LOS-ABV-001",
    "airline": "GiftAir",
    "validatingAirlineCodes": ["GP"],
    "from": "LOS",
    "to": "ABV",
    "depart": "08:00",
    "arrive": "09:15",
    "duration": "1h 15m",
    "price": "85000",
    "currency": "NGN",
    "itineraries": [
      {
        "duration": "PT1H15M",
        "segments": [
          {
            "departure": {"iataCode": "LOS", "at": "2026-12-01T08:00:00"},
            "arrival": {"iataCode": "ABV", "at": "2026-12-01T09:15:00"},
            "duration": "PT1H15M",
          },
        ],
      },
    ],
  },
  {
    "id": "GP-LOS-ABV-002",
    "airline": "GiftAir",
    "validatingAirlineCodes": ["GP"],
    "from": "LOS",
    "to": "ABV",
    "depart": "13:30",
    "arrive": "14:45",
    "duration": "1h 15m",
    "price": "92000",
    "currency": "NGN",
    "itineraries": [
      {
        "duration": "PT1H15M",
        "segments": [
          {
            "departure": {"iataCode": "LOS", "at": "2026-12-01T13:30:00"},
            "arrival": {"iataCode": "ABV", "at": "2026-12-01T14:45:00"},
            "duration": "PT1H15M",
          },
        ],
      },
    ],
  },
];

Map<String, dynamic> aviationMockBooking({
  required Map<String, dynamic> offer,
  required Map<String, dynamic> passenger,
}) => {
  "id": "GP-BOOK-${DateTime.now().millisecondsSinceEpoch}",
  "offer": offer,
  "passenger": passenger,
  "status": "created",
};

Map<String, dynamic> aviationMockTicket({
  required Map<String, dynamic> booking,
  required double total,
  required String paymentMethod,
}) => {
  "id": "GP-TKT-${DateTime.now().millisecondsSinceEpoch}",
  "pnr": "GP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
  "offer": booking["offer"],
  "passenger": booking["passenger"],
  "total": total,
  "paymentMethod": paymentMethod,
  "status": "confirmed",
  "qr": null,
};
