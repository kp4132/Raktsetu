import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/donor.dart';
import '../models/blood_request.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or your computer's local IP for physical phone
  static String baseUrl = 'http://10.0.2.2:5000';

  // Fallback sample data in case backend is offline
  static final List<Donor> _mockDonors = [
    Donor(id: 1, name: 'Rahul Sharma', bloodGroup: 'O+', age: 26, gender: 'Male', phone: '9876543210', city: 'Mumbai', isAvailable: true),
    Donor(id: 2, name: 'Priya Patel', bloodGroup: 'A+', age: 24, gender: 'Female', phone: '9876543211', city: 'Ahmedabad', isAvailable: true),
    Donor(id: 3, name: 'Amit Verma', bloodGroup: 'B+', age: 29, gender: 'Male', phone: '9876543212', city: 'Delhi', isAvailable: true),
    Donor(id: 4, name: 'Sneha Kulkarni', bloodGroup: 'O-', age: 27, gender: 'Female', phone: '9876543213', city: 'Pune', isAvailable: true),
    Donor(id: 5, name: 'Vikram Singh', bloodGroup: 'AB+', age: 32, gender: 'Male', phone: '9876543214', city: 'Jaipur', isAvailable: true),
    Donor(id: 6, name: 'Karthik Nair', bloodGroup: 'B-', age: 31, gender: 'Male', phone: '9876543216', city: 'Bengaluru', isAvailable: true),
  ];

  static final List<BloodRequest> _mockRequests = [
    BloodRequest(id: 1, patientName: 'Suresh Rao', bloodGroup: 'B+', units: 2, hospital: 'City Care Hospital', city: 'Mumbai', contactName: 'Kavita Rao', contactPhone: '9811223344', urgency: 'Critical', status: 'Open', note: 'Surgery tomorrow morning.'),
    BloodRequest(id: 2, patientName: 'Ramesh Chandra', bloodGroup: 'O-', units: 1, hospital: 'Apollo Hospital', city: 'Delhi', contactName: 'Sunita Chandra', contactPhone: '9822334455', urgency: 'Immediate', status: 'Open', note: 'Emergency ICU requirement.'),
  ];

  // Fetch Donors
  static Future<List<Donor>> getDonors({String? bloodGroup, String? city, bool compatible = false}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/donors').replace(queryParameters: {
        if (bloodGroup != null && bloodGroup.isNotEmpty) 'blood_group': bloodGroup,
        if (city != null && city.isNotEmpty) 'city': city,
        if (compatible) 'compatible': '1',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Donor.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback filter on mock data
    }

    return _mockDonors.where((d) {
      if (bloodGroup != null && bloodGroup.isNotEmpty && d.bloodGroup != bloodGroup) return false;
      if (city != null && city.isNotEmpty && !d.city.toLowerCase().contains(city.toLowerCase())) return false;
      return true;
    }).toList();
  }

  // Fetch Requests
  static Future<List<BloodRequest>> getRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/requests')).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BloodRequest.fromJson(json)).toList();
      }
    } catch (_) {}
    return _mockRequests;
  }

  // Register Donor
  static Future<bool> registerDonor(Donor donor) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/donors'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(donor.toJson()),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 201;
    } catch (_) {
      _mockDonors.insert(0, donor);
      return true;
    }
  }

  // Post Emergency Request
  static Future<bool> postRequest(BloodRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 201;
    } catch (_) {
      _mockRequests.insert(0, request);
      return true;
    }
  }

  // Launch Phone Call
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // Launch WhatsApp Message
  static Future<void> launchWhatsApp(String phoneNumber, String message) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final fullNumber = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    final Uri url = Uri.parse('https://wa.me/$fullNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
