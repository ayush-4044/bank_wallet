import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../CommonWidget/apiconst.dart';

class PaymentsPage extends StatefulWidget {
  @override
  PaymentsPage1 createState() => PaymentsPage1();
}

class PaymentsPage1 extends State<PaymentsPage> {
  List payment = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${Apiconst.base_url}admin_view_payment.php");
    var response = await http.get(
      url,
      headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
    );

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      setState(() {
        payment = decodedData["payment"] ?? [];

        // Sort by p_id in descending order (latest first)
        if (payment.isNotEmpty) {
          payment.sort((a, b) => int.parse(b['p_id']).compareTo(int.parse(a['p_id'])));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load payments")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  void _deletePayment(String paymentId) async {
    var url = Uri.parse("${Apiconst.base_url}admin_delete_payment.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "p_id": paymentId,
    });

    if (response.statusCode == 200) {
      setState(() {
        payment.removeWhere((item) => item['p_id'] == paymentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment deleted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete payment")),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: Text("Delete Payment"),
          content: Text("Are you sure you want to delete this payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePayment(paymentId);
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        title: Text(
          "Payment History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : payment.isEmpty
              ? Center(
                  child: Text(
                    'No Payment Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: payment.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Color(0xFFF5F5F5),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                label: 'Vehicle Name:',
                                value: payment[index]['v_name'],
                              ),
                              _buildInfoRow(
                                label: 'Agency Name:',
                                value: payment[index]['a_name'],
                              ),
                              _buildInfoRow(
                                label: 'User Name:',
                                value: payment[index]['u_name'],
                              ),
                              _buildInfoRow(
                                label: 'Amount:',
                                value: payment[index]['amount'],
                              ),
                              _buildInfoRow(
                                label: 'Payment Type:',
                                value: payment[index]['p_status'],
                              ),
                              _buildInfoRow(
                                label: 'Payment Time:',
                                value: payment[index]['timestamp'],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      payment[index]['p_id'],
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
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

  Widget _buildInfoRow({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value ?? "N/A",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
