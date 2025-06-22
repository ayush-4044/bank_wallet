import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookyourev/admin/admin_view_city.dart';
import 'package:bookyourev/admin/admin_view_bookings.dart';
import 'package:bookyourev/admin/admin_view_vehicles.dart';
import 'package:bookyourev/admin/admin_view_agencys.dart';
import 'package:bookyourev/admin/admin_view_category.dart';
import 'package:bookyourev/admin/admin_view_feedback.dart';
import 'package:bookyourev/login_screen.dart';
import 'package:bookyourev/admin/admin_view_payments.dart';
import 'package:bookyourev/admin/admin_view_users.dart';
import 'package:bookyourev/admin/admin_profile_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const Admin());
}

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminDashboardPage(),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardPage> {
  final List<Map<String, dynamic>> dashboardData = const [
    {
      "id": 0,
      "title": "City",
      "icon": Icons.location_city,
      "color": Colors.amber
    },
    {
      "id": 1,
      "title": "Category",
      "icon": Icons.category,
      "color": Colors.teal
    },
    {
      "id": 2,
      "title": "Vehicles",
      "icon": Icons.directions_car,
      "color": Colors.blue
    },
    {
      "id": 3,
      "title": "Bookings",
      "icon": Icons.book_online,
      "color": Colors.green
    },
    {
      "id": 4,
      "title": "Payments",
      "icon": Icons.payment,
      "color": Colors.purple
    },
    {
      "id": 5,
      "title": "Feedback",
      "icon": Icons.feedback,
      "color": Colors.cyan
    },
    {
      "id": 6,
      "title": "Manage User",
      "icon": Icons.verified_user,
      "color": Colors.blueGrey
    },
    {
      "id": 7,
      "title": "Manage Agency",
      "icon": Icons.business,
      "color": Colors.orange
    },
    {
      "id": 8,
      "title": "Logout",
      "icon": Icons.logout,
      "color": Colors.red
    },
  ];

  void _navigateToPage(BuildContext context, int id) {
    switch (id) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CityPage()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CategoryPage()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => VehiclesPage()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PaymentsPage()));
        break;
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedbackPage()));
        break;
      case 6:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserPage()));
        break;
      case 7:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AgencyPage()));
        break;
      case 8:
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: Text(
            "Logout",
          ),
          content: const Text(
            "Are You Sure You Want To Logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                final pref = await SharedPreferences.getInstance();
                await pref.clear();
                await pref.setBool('seen', true);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90), // Slightly taller for a modern look
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor:
                  Colors.transparent, // Keep it transparent to show gradient
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(
                    top: 10), // Pushes content down slightly
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminProfilePage()),
                            );
                          },
                          child: Container(
                            width: 45, // Set width of the circle
                            height: 45, // Set height of the circle
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white,
                                  width: 2), // White border
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/default_profile.jpeg',
                                fit: BoxFit
                                    .cover, // Cover the entire circular area without stretching
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Space between image & text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Book Your EV',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
          ),
          itemCount: dashboardData.length,
          itemBuilder: (context, index) {
            final data = dashboardData[index];
            return GestureDetector(
              onTap: () => _navigateToPage(context, data['id']),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: data['color'].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(data['icon'], size: 45, color: data['color']),
                    ).animate().scale(
                        begin: Offset(0.9, 0.9),
                        end: Offset(1.0, 1.0),
                        duration: 300.ms,
                        curve: Curves.easeOutBack),
                    const SizedBox(height: 12),
                    Text(
                      data['title'],
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: data['color']),
                      textAlign: TextAlign.center,
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
