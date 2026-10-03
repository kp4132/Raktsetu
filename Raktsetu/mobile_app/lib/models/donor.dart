class Donor {
  final int id;
  final String name;
  final String bloodGroup;
  final int age;
  final String gender;
  final String phone;
  final String? email;
  final String city;
  final String? state;
  final String? pincode;
  final String? lastDonationDate;
  final bool isAvailable;

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.age,
    required this.gender,
    required this.phone,
    this.email,
    required this.city,
    this.state,
    this.pincode,
    this.lastDonationDate,
    required this.isAvailable,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? 'Male',
      phone: json['phone'] ?? '',
      email: json['email'],
      city: json['city'] ?? '',
      state: json['state'],
      pincode: json['pincode'],
      lastDonationDate: json['last_donation_date'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'blood_group': bloodGroup,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email ?? '',
      'city': city,
      'state': state ?? '',
      'pincode': pincode ?? '',
      'last_donation_date': lastDonationDate ?? 'First Time',
    };
  }
}
