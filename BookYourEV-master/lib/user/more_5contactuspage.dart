import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CONTACT US',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reach out to us in various ways!',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              buildSection(Icons.location_on, 'Corporate Address',
                  'BookYourEV · 47, Phase IV, Udyog Vihar, Sector 8, Ahmedabad, Gujarat 382480.'),
              buildSection(
                  Icons.business,
                  'Regional Office Address',
                  'Goa: Basement-Lohia Building, Miramar, Tiswadi, North Goa, 403001.\n\n'
                      'Bangalore: No-168/13 Singasandra Lake, Building no 3 & 4, Hosur Road, Behind Dakshin Honda Showroom, Bengaluru, Karnataka, 560066.\n\n'
                      'Gurugram: Near Ara Machine, Khata no 591, Krishna Nagar, Gurugram, Haryana 122001.\n\n'
                      'Jaipur: Pink Square, Plot No. 1,2, Janta Colony, Govind Marg, Raja Park, Jaipur, Rajasthan, 302004.'),
              buildSection(Icons.email, 'Email', 'Contact@bookyourev'),
              buildSection(Icons.phone, 'Mobile', '+91 12345 67890'),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(FontAwesomeIcons.facebook, size: 30, color: Colors.blue),
                  SizedBox(width: 20),
                  Icon(FontAwesomeIcons.instagram,
                      size: 30, color: Colors.purple),
                  SizedBox(width: 20),
                  Icon(FontAwesomeIcons.linkedin,
                      size: 30, color: Colors.blueAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(IconData icon, String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(content, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
