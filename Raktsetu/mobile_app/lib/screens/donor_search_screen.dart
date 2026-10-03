import 'package:flutter/material.dart';
import '../models/donor.dart';
import '../services/api_service.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final List<String> bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  String selectedBloodGroup = 'All';
  final TextEditingController _cityController = TextEditingController();
  bool includeCompatible = true;
  List<Donor> donors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() => isLoading = true);
    final bg = selectedBloodGroup == 'All' ? null : selectedBloodGroup;
    final results = await ApiService.getDonors(
      bloodGroup: bg,
      city: _cityController.text.trim(),
      compatible: includeCompatible,
    );
    setState(() {
      donors = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Donors', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Filter Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blood group horizontal scroll chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bloodGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final bg = bloodGroups[index];
                      final isSelected = selectedBloodGroup == bg;
                      return ChoiceChip(
                        label: Text(bg, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: primaryRed,
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => selectedBloodGroup = bg);
                            _fetchDonors();
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // City search input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Search city (e.g. Mumbai, Pune)',
                          prefixIcon: const Icon(Icons.location_on, color: primaryRed, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _fetchDonors(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _fetchDonors,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Icon(Icons.search, size: 20),
                    ),
                  ],
                ),
                // Compatible checkbox
                Row(
                  children: [
                    Checkbox(
                      value: includeCompatible,
                      activeColor: primaryRed,
                      onChanged: (val) {
                        setState(() => includeCompatible = val ?? false);
                        _fetchDonors();
                      },
                    ),
                    const Text('Include compatible blood groups', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),

          // Donors List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryRed))
                : donors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No donors found matching criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            const Text('Try changing the city or blood group filter', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: donors.length,
                        itemBuilder: (context, index) {
                          final donor = donors[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 1.5,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: primaryRed,
                                        child: Text(donor.bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(donor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('${donor.gender}, ${donor.age} yrs • ${donor.city}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: donor.isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: donor.isAvailable ? Colors.green.shade200 : Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          donor.isAvailable ? 'Available' : 'Busy',
                                          style: TextStyle(color: donor.isAvailable ? Colors.green.shade700 : Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => ApiService.makePhoneCall(donor.phone),
                                          icon: const Icon(Icons.call, size: 16, color: primaryRed),
                                          label: const Text('Call', style: TextStyle(color: primaryRed)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: primaryRed),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => ApiService.launchWhatsApp(
                                            donor.phone,
                                            'Hello ${donor.name}, I found your contact on Blood Donor Finder. Are you available for a ${donor.bloodGroup} blood donation in ${donor.city}?',
                                          ),
                                          icon: const Icon(Icons.chat, size: 16),
                                          label: const Text('WhatsApp'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF25D366),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
