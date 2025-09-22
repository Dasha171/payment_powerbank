class Station {
  final String id;
  final String name;
  final String location;
  final bool isActive;
  final int availablePowerBanks;
  final int totalSlots;

  Station({
    required this.id,
    required this.name,
    required this.location,
    required this.isActive,
    required this.availablePowerBanks,
    required this.totalSlots,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      isActive: json['isActive'] ?? false,
      availablePowerBanks: json['availablePowerBanks'] ?? 0,
      totalSlots: json['totalSlots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'isActive': isActive,
      'availablePowerBanks': availablePowerBanks,
      'totalSlots': totalSlots,
    };
  }
}

class StationInfo {
  final String stationId;
  final String? stationName;
  final String? location;
  final bool isOperational;

  StationInfo({
    required this.stationId,
    this.stationName,
    this.location,
    this.isOperational = true,
  });

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    return StationInfo(
      stationId: json['stationId'] ?? '',
      stationName: json['stationName'],
      location: json['location'],
      isOperational: json['isOperational'] ?? true,
    );
  }
}
