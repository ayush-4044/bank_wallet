import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../CommonWidget/apiconst.dart';

class AgencyBookingsScreen extends StatefulWidget {
  const AgencyBookingsScreen({super.key});

  @override
  State<AgencyBookingsScreen> createState() => AgencyBookingsScreenState();
}

class AgencyBookingsScreenState extends State<AgencyBookingsScreen> {
  List bookingHistory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getBookingHistory();
  }

  _getBookingHistory() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse("${Apiconst.base_url}agency_view_booking.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "a_id": prefs.getString('uid')!,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error'] == false) {
        setState(() {
          bookingHistory = data['booking'];
          bookingHistory
              .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _showStatusConfirmationDialog(
      BuildContext context, String bookingId, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == '2' ? "Accept Booking" : "Reject Booking"),
          content: Text(status == '2'
              ? "Are you sure you want to accept this booking?"
              : "Are you sure you want to reject this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateBookingStatus(bookingId, status);
              },
              child: Text(
                status == '2' ? "Accept" : "Reject",
                style:
                    TextStyle(color: status == '2' ? Colors.green : Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateBookingStatus(String bookingId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse("${Apiconst.base_url}agency_accept_booking.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "booking_id": bookingId,
      "agency_id": prefs.getString('uid')!,
      "status": status,
    });
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error'] == false) {
        setState(() {
          bookingHistory.firstWhere(
              (booking) => booking['b_id'] == bookingId)['b_status'] = status;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        title: Text(
          "Booking History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : bookingHistory.isEmpty
              ? Center(
                  child: Text(
                    "No Bookings Available !",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: bookingHistory.length,
                  itemBuilder: (context, index) {
                    final booking = bookingHistory[index];

                    return Card(
                      color: Color(0xFFF5F5F5),
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
                              "Vehicle: ${booking['v_name'] ?? 'Unknown Vehicle'}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              "Start Date: ${booking['start_date']}",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "End Date: ${booking['end_date']}",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Start Time: ${booking['start_time']}",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "End Time: ${booking['end_time']}",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Amount: ₹${booking['total_amount']}",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (booking['b_status'] == '1') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _showStatusConfirmationDialog(context,
                                              booking['b_id'].toString(), '2'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Accept'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _showStatusConfirmationDialog(context,
                                              booking['b_id'].toString(), '3'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Reject'),
                                    ),
                                  ),
                                ],
                              )
                            ] else ...[
                              Text(
                                booking['b_status'] == '2'
                                    ? 'Accepted'
                                    : 'Rejected',
                                style: TextStyle(
                                  color: booking['b_status'] == '2'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
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
