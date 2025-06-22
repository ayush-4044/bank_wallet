import 'dart:convert';
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';
import 'user_8feedback_page.dart';
import 'package:http/http.dart ' as http;

class BookingHistoryPage extends StatefulWidget {
  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  Set<String> feedbackSubmitted = {};
  String userid = "";
  bool isLoading = false;
  var booking;
  String? data;

  @override
  void initState() {
    super.initState();
    getBookingHistory();
    _loadSubmittedFeedback();
  }

  void getBookingHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
      userid = prefs.getString('uid') ?? ""; // Avoid null errors
    });

    var url = Uri.parse("${Apiconst.base_url}user_view_bookinghistory.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "u_id": userid // Ensure the request contains user ID
    });

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        var responseData = jsonDecode(response.body);
        List<dynamic> bookings =
            responseData["booking"] ?? []; // Ensure it’s a list
        bookings = bookings.where((b) => b['b_status'] != '0').toList();

        // Sort bookings by timestamp in descending order (latest first)
        bookings.sort((a, b) {
          DateTime dateA =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(a['timestamp']);
          DateTime dateB =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(b['timestamp']);
          return dateB.compareTo(dateA); // Sort latest to oldest
        });

        setState(() {
          booking = bookings;
          isLoading = false;
        });
      } catch (e) {
        print("Error decoding JSON: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("Error: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSubmittedFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      feedbackSubmitted =
          prefs.getStringList('feedbackSubmitted')?.toSet() ?? {};
    });
  }

  Future<void> _saveSubmittedFeedback(String vehicleName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    feedbackSubmitted.add(vehicleName);
    await prefs.setStringList('feedbackSubmitted', feedbackSubmitted.toList());
    setState(() {});
  }

  void _showCancelDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                _cancelBooking(index); // Call cancel API
              },
              child: Text('Yes', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(int index) async {
    String bookingId = booking[index]['b_id']; // Fetch booking ID from list
    String userId = userid; // Use stored user ID

    var url = Uri.parse("${Apiconst.base_url}user_cancel_booking.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "b_id": bookingId,
      "u_id": userId,
    });

    print(response.body);
    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData["error"] == false) {
      setState(() {
        booking.removeAt(index); // Remove canceled booking from list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your booking has been cancelled successfully.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData["message"] ?? 'Failed to cancel booking.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getBookingStatusText(String? status) {
    switch (status) {
      case '1':
        return 'Pending';
      case '2':
        return 'Accepted';
      case '3':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserDashboardPage()))),
        title: Text('Booking History',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
      backgroundColor: Colors.white,
      body: booking == null || booking.isEmpty
          ? Center(
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.green)
                  : Text("No bookings found."),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: booking.length,
              itemBuilder: (context, index) {
                DateTime endDate = DateFormat('yyyy-MM-dd')
                    .parse(booking[index]['end_date'] ?? "2025-01-01");
                DateTime startDate = DateFormat('yyyy-MM-dd')
                    .parse(booking[index]['start_date'] ?? "2025-01-01");
                DateTime currentDate = DateTime.now();
                bool showFeedbackButton = endDate.isBefore(currentDate) &&
                    !feedbackSubmitted.contains(booking[index]['end_date']);
                bool showCancelButton = startDate.isAfter(currentDate);

                return Card(
                  color: Color(0xFFF5F5F5), // Light Grey
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking[index]['vehicle_name'] ?? 'Unknown Vehicle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Booking Date:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(booking[index]['timestamp'] ?? 'N/A',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Start Date:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(booking[index]['start_date'] ?? 'N/A',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('End Date:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(booking[index]['end_date'] ?? 'N/A',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount Paid:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(
                              booking[index]['total_amount'] ?? '₹0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Booking Status:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(
                              _getBookingStatusText(booking[index]['b_status']),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (booking[index]['b_status'] == "2") ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agency Address:',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                booking[index]['a_address'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                        ],
                        if (showCancelButton) ...[
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showCancelDialog(context, index),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text('Cancel Booking',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        if (showFeedbackButton) ...[
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserFeedbackPage(
                                    vehicleName: booking[index]
                                        ['vehicle_name']!,
                                    bookingID: booking[index]['b_id']!,
                                    vehicleID: booking[index]['v_id']!,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _saveSubmittedFeedback(
                                    booking[index]['vehicle_name']!);
                              }
                            },
                            child: Text('Give Feedback',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ] else if (endDate.isBefore(currentDate)) ...[
                          SizedBox(height: 8),
                          Text(
                            'Feedback Submitted ✅',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
