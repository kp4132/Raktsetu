import 'package:flutter/material.dart';
import '../models/donor.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  String selectedBloodGroup = 'O+';
  String selectedGender = 'Male';
  bool pledgeAccepted = false;
  bool isSubmitting = false;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> genders = ['Male', 'Female', 'Other'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!pledgeAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the voluntary donor pledge')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final donor = Donor(
      id: 0,
      name: _nameController.text.trim(),
      bloodGroup: selectedBloodGroup,
      age: int.tryParse(_ageController.text.trim()) ?? 25,
      gender: selectedGender,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      lastDonationDate: 'First Time',
      isAvailable: true,
    );

    final success = await ApiService.registerDonor(donor);

    setState(() => isSubmitting = false);

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('🎉 Registration Successful!'),
            content: Text('Thank you ${_nameController.text}, you are now registered as a life-saving blood donor.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _formKey.currentState!.reset();
                  setState(() {
                    pledgeAccepted = false;
                  });
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit registration. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD90429), Color(0xFF900C1E)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Be a Lifesaver', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Join our voluntary network', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 4),
                    Text('Every unit of donated blood can save up to 3 lives.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person, color: primaryRed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),

              // Blood Group & Age row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedBloodGroup,
                      decoration: InputDecoration(
                        labelText: 'Blood Group *',
                        prefixIcon: const Icon(Icons.bloodtype, color: primaryRed),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                      onChanged: (val) => setState(() => selectedBloodGroup = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age (18-65) *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        final age = int.tryParse(val ?? '');
                        if (age == null || age < 18 || age > 65) return '18-65';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Gender Selector
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: const Icon(Icons.wc, color: primaryRed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGender = val!),
              ),
              const SizedBox(height: 14),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '10-Digit Mobile Number *',
                  prefixIcon: const Icon(Icons.phone, color: primaryRed),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val != null && RegExp(r'^\d{10}$').hasMatch(val.trim()) ? null : 'Enter valid 10-digit number',
              ),
              const SizedBox(height: 14),

              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City / Location *',
                  prefixIcon: const Icon(Icons.location_city, color: primaryRed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter your city' : null,
              ),
              const SizedBox(height: 14),

              // Email (Optional)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address (Optional)',
                  prefixIcon: const Icon(Icons.email, color: primaryRed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Voluntary Pledge Checkbox
              CheckboxListTile(
                value: pledgeAccepted,
                activeColor: primaryRed,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I confirm that I am in good health, weigh at least 45 kg, and volunteer to donate blood willingly.',
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (val) => setState(() => pledgeAccepted = val ?? false),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register as Blood Donor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
