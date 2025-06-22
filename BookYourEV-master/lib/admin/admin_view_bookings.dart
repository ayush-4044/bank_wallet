import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../CommonWidget/apiconst.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool isLoading = false;
  List<dynamic> booking = [];
  int selectedStatus = 2; // Default: Accepted

  final Map<int, String> statusLabels = {
    1: "Pending",
    2: "Accepted",
    3: "Rejected",
    0: "Canceled"
  };

  @override
  void initState() {
    super.initState();
    getBooking(selectedStatus);
  }

  void getBooking(int status) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${Apiconst.base_url}admin_view_booking.php");
    var response = await http.post(
      url,
      headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent,
      },
      body: {
        "b_status": status.toString(),
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error'] == false) {
        setState(() {
          booking = data["booking"];

          // Sort by b_id in descending order to get latest booking first
          booking.sort((a, b) =>
              int.parse(b['b_id'].toString()).compareTo(int.parse(a['b_id'].toString())));
        });
      } else {
        setState(() {
          booking = [];
        });
      }
    } else {
      setState(() {
        booking = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }


  void _deleteBooking(String bookingId) async {
    var url = Uri.parse("${Apiconst.base_url}admin_delete_booking.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "b_id": bookingId,
    });

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        // Convert b_id to string before comparing
        booking.removeWhere((item) => item['b_id'].toString() == bookingId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking deleted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete Booking")),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: Text("Delete Booking"),
          content: Text("Are you sure you want to delete this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBooking(bookingId);
              },
              child: Text("Yes", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text("Booking History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<int>(
              value: selectedStatus,
              dropdownColor: Colors.white,
              items: statusLabels.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value,
                            style: const TextStyle(color: Colors.black)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                  getBooking(value);
                }
              },
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : booking.isEmpty
                    ? const Center(child: Text("No Booking found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: booking.length,
                        itemBuilder: (context, index) {
                          var b = booking[index];

                          int bStatusInt =
                              int.tryParse(b['b_status'].toString()) ?? -1;
                          String bookingStatus =
                              statusLabels[bStatusInt] ?? "Unknown";

                          return Card(
                            color: Color(0xFFF5F5F5),
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                      'Agency:', b['agency_name'].toString()),
                                  _infoRow('User:', b['user_name'].toString()),
                                  _infoRow(
                                      'Vehicle:', b['vehicle_name'].toString()),
                                  _infoRow('Start Date:',
                                      b['start_date'].toString()),
                                  _infoRow(
                                      'End Date:', b['end_date'].toString()),
                                  _infoRow('Start Time:',
                                      b['start_time'].toString()),
                                  _infoRow(
                                      'End Time:', b['end_time'].toString()),
                                  _infoRow('Booking Status:', bookingStatus,
                                      color: Colors.green),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(context,
                                            booking[index]['b_id'].toString());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text("Delete",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.grey[700])),
        ],
      ),
    );
  }
}
