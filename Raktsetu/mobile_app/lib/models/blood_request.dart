class BloodRequest {
  final int id;
  final String patientName;
  final String bloodGroup;
  final int units;
  final String hospital;
  final String city;
  final String contactName;
  final String contactPhone;
  final String urgency;
  final String status;
  final String? note;
  final String? createdAt;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.city,
    required this.contactName,
    required this.contactPhone,
    required this.urgency,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      patientName: json['patient_name'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      units: json['units'] is int ? json['units'] : int.tryParse(json['units'].toString()) ?? 1,
      hospital: json['hospital'] ?? '',
      city: json['city'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      urgency: json['urgency'] ?? 'Urgent',
      status: json['status'] ?? 'Open',
      note: json['note'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'units': units,
      'hospital': hospital,
      'city': city,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'urgency': urgency,
      'note': note ?? '',
    };
  }
}
