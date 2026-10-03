import 'package:flutter/material.dart';
import 'donor_search_screen.dart';
import 'register_screen.dart';
import 'emergency_feed_screen.dart';
import 'matrix_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardTab(),
    const DonorSearchScreen(),
    const RegisterScreen(),
    const EmergencyFeedScreen(),
    const MatrixScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Donors'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 28), label: 'Register'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Urgent'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Matrix'),
        ],
      ),
    );
  }
}

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.water_drop, color: primaryRed, size: 26),
            SizedBox(width: 8),
            Text('RaktSetu', style: TextStyle(fontWeight: FontWeight.extrabold, color: Colors.black87)),
            SizedBox(width: 4),
            Text('Donor App', style: TextStyle(fontSize: 12, color: primaryRed, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD90429), Color(0xFF900C1E)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: primaryRed.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('EMERGENCY BLOOD NETWORK', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 8),
                  Text('Find Voluntary Donors\nSave a Life Today', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.extrabold, height: 1.2)),
                  SizedBox(height: 8),
                  Text('Direct phone & WhatsApp contact with verified donors across your city.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Network Stats Row
            Row(
              children: [
                _buildStatCard('12+', 'Donors', Icons.people, Colors.blue),
                const SizedBox(width: 10),
                _buildStatCard('100%', 'Free & Open', Icons.favorite, Colors.green),
                const SizedBox(width: 10),
                _buildStatCard('8', 'Cities', Icons.location_city, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Title
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Search Donors',
                    subtitle: 'By blood group & city',
                    icon: Icons.person_search,
                    color: Colors.red.shade700,
                    onTap: () {
                      final state = context.findAncestorStateOfType<_HomeScreenState>();
                      state?.setState(() => state._currentIndex = 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Become Donor',
                    subtitle: 'Sign up in 1 min',
                    icon: Icons.volunteer_activism,
                    color: Colors.green.shade700,
                    onTap: () {
                      final state = context.findAncestorStateOfType<_HomeScreenState>();
                      state?.setState(() => state._currentIndex = 2);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Emergency Feed',
                    subtitle: 'Critical patient needs',
                    icon: Icons.emergency,
                    color: Colors.amber.shade800,
                    onTap: () {
                      final state = context.findAncestorStateOfType<_HomeScreenState>();
                      state?.setState(() => state._currentIndex = 3);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Blood Matrix',
                    subtitle: 'Matching guide',
                    icon: Icons.schema,
                    color: Colors.purple.shade700,
                    onTap: () {
                      final state = context.findAncestorStateOfType<_HomeScreenState>();
                      state?.setState(() => state._currentIndex = 4);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Helpline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: primaryRed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('National Emergency Helplines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryRed)),
                        Text('Call 108 (Ambulance) or 104 (Blood Bank Info)', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => ApiService.makePhoneCall('108'),
                    child: const Text('Call 108', style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 16)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
