import 'package:flutter/material.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  String selectedBg = 'O+';

  final Map<String, List<String>> donorToRecipients = {
    'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
    'O+': ['O+', 'A+', 'B+', 'AB+'],
    'A-': ['A-', 'A+', 'AB-', 'AB+'],
    'A+': ['A+', 'AB+'],
    'B-': ['B-', 'B+', 'AB-', 'AB+'],
    'B+': ['B+', 'AB+'],
    'AB-': ['AB-', 'AB+'],
    'AB+': ['AB+'],
  };

  final Map<String, List<String>> recipientFromDonors = {
    'O-': ['O-'],
    'O+': ['O+', 'O-'],
    'A-': ['A-', 'O-'],
    'A+': ['A+', 'A-', 'O+', 'O-'],
    'B-': ['B-', 'O-'],
    'B+': ['B+', 'B-', 'O+', 'O-'],
    'AB-': ['AB-', 'A-', 'B-', 'O-'],
    'AB+': ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'],
  };

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);
    final canDonateTo = donorToRecipients[selectedBg] ?? [];
    final canReceiveFrom = recipientFromDonors[selectedBg] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Compatibility Matrix', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Blood Group to Check Matching',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Blood group buttons wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'].map((bg) {
                final isSelected = selectedBg == bg;
                return ChoiceChip(
                  label: Text(bg, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: primaryRed,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    if (selected) setState(() => selectedBg = bg);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Can Donate To Card
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('$selectedBg Can DONATE Red Cells To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: canDonateTo.map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: Colors.green.shade700,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Can Receive From Card
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('$selectedBg Can RECEIVE Red Cells From:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: canReceiveFrom.map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: Colors.blue.shade700,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Fast Facts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('💡 Quick Life-Saving Facts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('• O Negative (O-) is the Universal Donor and can be given to all blood types in emergencies.'),
                  SizedBox(height: 4),
                  Text('• AB Positive (AB+) is the Universal Recipient and can safely accept red cells from any blood type.'),
                  SizedBox(height: 4),
                  Text('• Whole blood donation takes only 10-15 minutes and regenerates within 24-48 hours.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
