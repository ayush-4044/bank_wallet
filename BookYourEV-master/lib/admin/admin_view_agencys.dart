import 'dart:convert';
import 'package:flutter/material.dart';
import '../CommonWidget/apiconst.dart'; // Adjust the import path as needed
import 'package:http/http.dart' as http;

class AgencyPage extends StatefulWidget {
  const AgencyPage({super.key});

  @override
  State<AgencyPage> createState() => _AgencyPageState();
}

class _AgencyPageState extends State<AgencyPage> {
  String? data;
  List<dynamic> agency = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  bool isLoading = false;

  void getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse("${Apiconst.base_url}admin_view_agency.php");
      var response = await http.get(
        url,
        headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
      );

      if (response.statusCode == 200) {
        List<dynamic> agencyList = jsonDecode(response.body)["agency"] ?? [];
        agencyList.sort((a, b) {
          int timestampComparison = b['timestamp'].compareTo(a['timestamp']);
          if (timestampComparison == 0) {
            return int.parse(b['a_id']).compareTo(int.parse(a['a_id']));
          }
          return timestampComparison;
        });

        setState(() {
          agency = agencyList;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteAgency(String agencyId) async {
    var url = Uri.parse("${Apiconst.base_url}admin_delete_agency.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "a_id": agencyId,
    });

    var data = jsonDecode(response.body);
    if (data['error'] == false) {
      setState(() {
        agency.removeWhere(
            (item) => item['a_id'].toString() == agencyId); // ✅ Fix applied
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agency deleted successfully"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete agency"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(String agencyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: const Text(
            "Confirm Deletion",
          ),
          content: const Text("Are you sure you want to delete this agency?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAgency(agencyId);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.black)),
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
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Text(
          'Manage Agency',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : agency.isEmpty
              ? Center(
                  child: Text(
                    'No Agency\'s Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    getData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: agency.length,
                    itemBuilder: (context, index) {
                      return AgencyCard(
                        agency: agency[index],
                        onDelete: () => _showDeleteConfirmation(
                            agency[index]['a_id'].toString()),
                      );
                    },
                  ),
                ),
    );
  }
}

class AgencyCard extends StatelessWidget {
  final Map<String, dynamic> agency;
  final VoidCallback onDelete;

  const AgencyCard({required this.agency, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildDetailRow('Name:', agency['a_name'] ?? 'N/A'),
            _buildDetailRow('Email:', agency['a_email'] ?? 'N/A'),
            _buildDetailRow('Phone:', agency['a_phone'] ?? 'N/A'),

            // Address Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agency['a_address'] ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.4),
                    softWrap: true,
                  ),
                ],
              ),
            ),

            // License Verification Section
            const SizedBox(height: 8),
            Text(
              'License:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            _buildVerificationImage(agency['a_verification']),

            // Status Section
            const SizedBox(height: 8),
            _buildDetailRow('Agency Status:', agency['a_status'] ?? 'N/A',
                isStatus: true),

            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Delete Agency",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          const Spacer(), // Pushes the value to the right
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isStatus ? 16 : 14,
              fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
              color: isStatus ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'No verification document available',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}

