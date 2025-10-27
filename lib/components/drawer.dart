import 'package:flutter/material.dart';
import 'package:mqtt_test/pages/alarm_history.dart';
import 'package:mqtt_test/pages/user_settings.dart';
import 'package:mqtt_test/pages/about_page.dart';
import 'package:mqtt_test/pages/login_form.dart';
import '../api/api_service.dart';

class NavDrawer extends StatelessWidget {
  final String username;
  final String email;

  const NavDrawer.data({Key? key, required this.username, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            //const Divider(color: Colors.white24, thickness: 0.5),
            _buildTile(context, Icons.history, "History",
                    () => _navigate(context, const AlarmHistory())),
            const Divider(color: Colors.white24, thickness: 0.5),
            _buildTile(context, Icons.settings, "Settings",
                    () => _navigate(context, const UserSettings.base())),
            const Divider(color: Colors.white24, thickness: 0.5),
            _buildTile(context, Icons.info_outline, "About",
                    () => _navigate(context, const AboutPage.base())),
            const Divider(color: Colors.white24, thickness: 0.5),
            _buildTile(
              context,
              Icons.logout,
              "Log out",
                  () async {
                await ApiService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginForm.base()),
                        (route) => false);
              },
              color: Colors.redAccent,
            ),
            const Divider(color: Colors.white24, thickness: 0.5),

          ],
        ),
      ),
    );
  }
/*

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blueAccent, size: 45),
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

 */
  Widget _buildHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
      ),
      accountName: Text(
        "   "+username,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      accountEmail: Text(
        "    "+email,
        style: const TextStyle(fontSize: 13, color: Colors.white70),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title,
      VoidCallback onTap,
      {Color color = Colors.white70}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, letterSpacing: 1.2, fontSize: 15),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }
}