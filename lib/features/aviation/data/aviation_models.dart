class AviationPassenger {
  final String firstName;
  final String lastName;
  final String dob;
  final String passport;
  final String nationality;

  const AviationPassenger({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.passport,
    required this.nationality,
  });

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "dob": dob,
    "passport": passport,
    "nationality": nationality,
  };
}

class AviationSearchRequest {
  final String from;
  final String to;
  final String date;
  final int passengers;
  final String cabin;

  const AviationSearchRequest({
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    required this.cabin,
  });

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "date": date,
    "passengers": passengers,
    "cabin": cabin,
  };
}

class AviationBookingRequest {
  final String offerId;
  final AviationPassenger passenger;

  const AviationBookingRequest({
    required this.offerId,
    required this.passenger,
  });

  Map<String, dynamic> toJson() => {
    "offerId": offerId,
    "passenger": passenger.toJson(),
  };
}
