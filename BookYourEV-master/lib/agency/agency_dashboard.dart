import 'package:bookyourev/agency/agency_view_bookings.dart';
import 'package:bookyourev/agency/agency_view_feedback.dart';
import 'package:bookyourev/agency/agency_view_payments.dart';
import 'package:bookyourev/agency/agency_view_profile.dart';
import 'package:bookyourev/agency/agency_view_all_vehicles.dart';
import 'package:flutter/material.dart';
import 'package:bookyourev/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgencyDashboard extends StatefulWidget {
  const AgencyDashboard({super.key});

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard> {
  String currentCity = '';

  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> imagePaths = [
    "assets/images/Agency_Dashboard_1.jpg",
    "assets/images/Agency_Dashboard_2.jpg",
    "assets/images/Agency_Dashboard_3.jpg",
  ];

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCity = prefs.getString('selectedCity')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getSelectedValue();
    _autoScroll();
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % imagePaths.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
        );
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  currentCity,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePaths[index],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imagePaths.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(entry.key,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.ease),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.green)
                            .withOpacity(
                                _currentPage == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return ProfileCard(
                        title: 'Profile',
                        icon: Icons.person_outlined,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyProfileScreen(),
                            ),
                          );
                        },
                      );
                    case 1:
                      return ProfileCard(
                        title: 'Vehicles',
                        icon: Icons.car_repair,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyVehicleScreen(),
                            ),
                          );
                        },
                      );
                    case 2:
                      return ProfileCard(
                        title: 'Bookings',
                        icon: Icons.book_online,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyBookingsScreen(),
                            ),
                          );
                        },
                      );
                    case 3:
                      return ProfileCard(
                        title: 'Payments',
                        icon: Icons.payment,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyPaymentsScreen(),
                            ),
                          );
                        },
                      );
                    case 4:
                      return ProfileCard(
                        title: 'Feedback',
                        icon: Icons.feedback,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgencyFeedbackScreen(),
                            ),
                          );
                        },
                      );
                    case 5:
                      return ProfileCard(
                        title: 'Logout',
                        icon: Icons.logout,
                        color: Colors.red,
                        onTap: () => _showLogoutDialog(context),
                      );
                    default:
                      return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
              child: Text("No", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
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
                  (Route<dynamic> route) => false,
                );
                // Add logout functionality here (e.g., clear session or user data)
              },
            ),
          ],
        );
      },
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProfileCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
