import 'package:flutter/material.dart';
import 'package:bookyourev/user/user_3bookinghistorypage.dart';
import 'package:bookyourev/user/user_1homepage.dart';
import 'package:bookyourev/user/user_4morepage.dart';
import 'user_2searchpage.dart';

class UserDashboardPage extends StatefulWidget {
  @override
  UserDashboardPageState createState() => UserDashboardPageState();
}

class UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      Homepage(
        onSeeAllTap: () => changePage(1),
      ),
      SearchPage(),
      BookingHistoryPage(),
      MorePage(),
    ];
  }

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.search, "Search", 1),
              _buildNavItem(Icons.history, "Bookings", 2),
              _buildNavItem(Icons.more_horiz, "More", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(vertical: 0, horizontal: isSelected ? 14 : 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey[600],
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.green : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
