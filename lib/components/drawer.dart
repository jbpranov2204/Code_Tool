import 'package:flutter/material.dart';

class ResponsiveDrawer extends StatelessWidget {
  final VoidCallback onCodeReviewTap;
  final VoidCallback onDebugThisCodeForMeTap;
  final VoidCallback onGitRepoReviewTap;

  ResponsiveDrawer({
    super.key,
    required this.onCodeReviewTap,
    required this.onDebugThisCodeForMeTap,
    required this.onGitRepoReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        width: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Image/logo.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Code Review'),
                onTap: onCodeReviewTap,
                leading: Icon(Icons.code),
              ),
              ListTile(
                title: Text('Debug this code for me'),
                onTap: onDebugThisCodeForMeTap,
                leading: Icon(Icons.bug_report),
              ),
              ListTile(
                title: Text('Git Repo Review'),
                onTap: onGitRepoReviewTap, // Enable functionality
                leading: Icon(Icons.gite_outlined),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListTile(
              leading: ClipOval(
                child: CircleAvatar(
                  radius: 25,
                  child: Image.network(
                    'https://images6.alphacoders.com/130/1307179.jpeg',
                  ),
                ),
              ),
              title: Text('Spy', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
    );
  }
}
