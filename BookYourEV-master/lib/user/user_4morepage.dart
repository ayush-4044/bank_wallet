import 'package:bookyourev/login_screen.dart';
import 'package:bookyourev/user/more_3privacypage.dart';
import 'package:bookyourev/user/more_2termspage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'more_4aboutuspage.dart';
import 'more_5contactuspage.dart';
import 'more_7faqpage.dart';
import 'more_6invitefriendpage.dart';
import 'more_1myprofilepage.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  String userName = "";

  @override
  void initState() {
    getSelectedValue();
    super.initState();
  }

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('uname')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade400,
      body: Column(
        children: [
          SizedBox(height: 50),
          Icon(Icons.account_circle, size: 80, color: Colors.white),
          SizedBox(height: 10),
          Text(
            userName,
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.green.shade500),
                    title: Text('My Profile', style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyProfilePage()),
                      ).whenComplete(() {
                        getSelectedValue();
                      });
                    },
                  ),
                  _buildMenuItem(context, Icons.description,
                      'Terms & Conditions', TermsPage()),
                  _buildMenuItem(context, Icons.privacy_tip, 'Privacy Policy',
                      PrivacyPolicyPage()),
                  _buildMenuItem(
                      context, Icons.info, 'About Us', AboutUsPage()),
                  _buildMenuItem(
                      context, Icons.phone, 'Contact Us', ContactUsPage()),
                  _buildMenuItem(context, Icons.card_giftcard,
                      'Invite your friend', InviteFriendPage()),
                  _buildMenuItem(context, Icons.help, 'FAQ', FAQPage()),
                  _buildLogoutMenuItem(context, Icons.exit_to_app, 'Logout'),
                  Center(
                      child: Text('Version 2.0.32(113)',
                          style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade500),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Widget _buildLogoutMenuItem(
      BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade500),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        _showLogoutDialog(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: Text("Logout"),
          content: Text("Are You Sure You Want To Logout?"),
          actions: [
            TextButton(
              child: Text(
                "No",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                final pref = await SharedPreferences.getInstance();
                await pref.clear();
                await pref.setBool('seen', true);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen()),
                    (Route<dynamic> route) => false);
                // Add logout functionality here
              },
            ),
          ],
        );
      },
    );
  }
}
