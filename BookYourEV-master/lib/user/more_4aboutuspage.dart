import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ABOUT US",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(
              title: "MEET BOOK YOUR EV",
              content:
                  "Book Your EV was founded on a simple idea of FREEDOM in mobility.\n\nWe felt that like everything in today’s world, mobility also needed an update. Thus began our quest to create a Smart, Affordable and accessible mobility option. Book Your EV provides safe, happy and reliable commute services to our customers, through non-exclusive self-driving two-wheelers.\nBook Your EV for a sustainable tomorrow aims to reduce dependence on personal vehicle and Ownership by introducing User-ship through shared vehicles, and in the process leaving the planet a bit healthier. Choose Freedom to Move, Choose Freedo!",
            ),
            _buildSection(
              icon: Icons.directions_bike,
              title: "OUR VISION",
              content:
                  "To democratize micro mobility as a service by removing all roadblocks between people and mobility.\n\n\"We thrive to make mobility so ingrained in your lifestyle that it becomes a fundamental right\"",
            ),
            _buildSection(
              icon: Icons.track_changes,
              title: "OUR MISSION",
              content:
                  "To constantly evolve and provide micro mobility solutions by solving the problem of daily transportation.\n\n\"Helping commuters and travelers get to exactly where they need to go through innovative solutions\"",
            ),
            SizedBox(height: 20),
            _buildPillars(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection({required String title, required String content}) {
    return Card(
      color: Color(0xFFF5F5F5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required String content}) {
    return Card(
      color: Color(0xFFF5F5F5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillars() {
    return Card(
      color: Color(0xFFF5F5F5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "OUR THREE PILLARS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPillar(Icons.favorite, "Empathy"),
                _buildPillar(Icons.lightbulb, "Innovation"),
                _buildPillar(Icons.groups, "Team Work"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillar(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.orange),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
