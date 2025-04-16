import 'package:flutter/material.dart';

class ResponsiveDrawer extends StatelessWidget {
  final VoidCallback onCodeReviewTap;
  final VoidCallback onDebugThisCodeForMeTap;

  ResponsiveDrawer({
    super.key,
    required this.onCodeReviewTap,
    required this.onDebugThisCodeForMeTap,
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
              ),
              ListTile(
                title: Text('Debug this code for me'),
                onTap: onDebugThisCodeForMeTap,
              ),
              Container(child: ListTile(title: Text('Git Repo review')))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListTile(
              leading: ClipOval(
                child: CircleAvatar(
                  radius: 25,
                  child: Image.network(
                      'https://images6.alphacoders.com/130/1307179.jpeg'),
                ),
              ),
              title: Text(
                'Spy',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
    );
  }
}