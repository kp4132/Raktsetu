import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../services/api_service.dart';

class EmergencyFeedScreen extends StatefulWidget {
  const EmergencyFeedScreen({super.key});

  @override
  State<EmergencyFeedScreen> createState() => _EmergencyFeedScreenState();
}

class _EmergencyFeedScreenState extends State<EmergencyFeedScreen> {
  List<BloodRequest> requests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);
    final results = await ApiService.getRequests();
    setState(() {
      requests = results;
      isLoading = false;
    });
  }

  void _showPostRequestDialog() {
    final patientController = TextEditingController();
    final hospitalController = TextEditingController();
    final cityController = TextEditingController();
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();
    final noteController = TextEditingController();
    String selectedBg = 'B+';
    String urgency = 'Immediate';
    int units = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Post Emergency Blood Need', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(labelText: 'Patient Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedBg,
                        decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedBg = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: urgency,
                        decoration: const InputDecoration(labelText: 'Urgency', border: OutlineInputBorder()),
                        items: ['Critical', 'Immediate', 'Within 24 Hours']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setModalState(() => urgency = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(labelText: 'Hospital Name & Branch *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactNameController,
                  decoration: const InputDecoration(labelText: 'Attendant / Contact Person *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number *', prefixText: '+91 ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Additional Notes / ICU Bed Info', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (patientController.text.trim().isEmpty || hospitalController.text.trim().isEmpty || contactPhoneController.text.trim().isEmpty) {
                        return;
                      }
                      final newReq = BloodRequest(
                        id: 0,
                        patientName: patientController.text.trim(),
                        bloodGroup: selectedBg,
                        units: units,
                        hospital: hospitalController.text.trim(),
                        city: cityController.text.trim(),
                        contactName: contactNameController.text.trim(),
                        contactPhone: contactPhoneController.text.trim(),
                        urgency: urgency,
                        status: 'Open',
                        note: noteController.text.trim(),
                      );
                      await ApiService.postRequest(newReq);
                      Navigator.pop(ctx);
                      _fetchRequests();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD90429),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Broadcast Emergency Need', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostRequestDialog,
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert),
        label: const Text('Post Need', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryRed))
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              color: primaryRed,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final isCritical = req.urgency == 'Critical';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isCritical ? primaryRed : Colors.orange.shade700,
                                child: Text(req.bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(req.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${req.hospital}, ${req.city}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCritical ? Colors.red.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isCritical ? Colors.red.shade200 : Colors.amber.shade200),
                                ),
                                child: Text(
                                  req.urgency,
                                  style: TextStyle(color: isCritical ? primaryRed : Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Requirement: ${req.units} Unit(s) • Contact: ${req.contactName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          if (req.note != null && req.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('"${req.note}"', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 12)),
                          ],
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => ApiService.makePhoneCall(req.contactPhone),
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
                                    req.contactPhone,
                                    'Hello ${req.contactName}, I saw your emergency request for ${req.bloodGroup} blood at ${req.hospital}, ${req.city}. I am ready to donate.',
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
    );
  }
}
