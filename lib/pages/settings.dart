import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Account'),
          _buildListTile(
            Icons.person_outline,
            'Profile',
            'Update your info',
            onTap: () {},
          ),
          _buildListTile(
            Icons.lock_outline,
            'Security',
            'Passwords & more',
            onTap: () {},
          ),

          SizedBox(height: 20),
          _buildSectionTitle('Preferences'),
          _buildListTile(
            Icons.language_outlined,
            'Language',
            'Select preferred language',
            onTap: () {},
          ),
          _buildListTile(
            Icons.dark_mode_outlined,
            'Appearance',
            'Light / Dark themes',
            onTap: () {},
          ),

          SizedBox(height: 20),
          _buildSectionTitle('Others'),
          _buildListTile(
            Icons.info_outline,
            'About',
            'Version and app info',
            onTap: () {},
          ),
          _buildListTile(
            Icons.logout_outlined,
            'Logout',
            'Sign out of your account',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.grey[300],
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
      ),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
    );
  }
}
