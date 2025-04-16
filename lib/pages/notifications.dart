import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications_none, color: Colors.grey[600]),
            title: Text(
              'Notification Title $index',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'This is a short description for notification $index.',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
            ),
            onTap: () {
              // Handle tap on notification
            },
          );
        },
        separatorBuilder:
            (context, index) => Divider(color: Colors.grey[800], thickness: 1),
      ),
    );
  }
}
