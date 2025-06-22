import 'dart:convert';
import 'package:flutter/material.dart';
import '../CommonWidget/apiconst.dart'; // Adjust the import path as needed
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? data;
  List<dynamic> users = [];
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

    try {
      var url = Uri.parse("${Apiconst.base_url}admin_view_user.php");
      var response = await http.get(
        url,
        headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
      );

      if (response.statusCode == 200) {
        List<dynamic> userList = jsonDecode(response.body)["users"];

        userList.sort((a, b) {
          int timestampComparison = b['timestamp'].compareTo(a['timestamp']);
          if (timestampComparison == 0) {
            return int.parse(b['u_id']).compareTo(int.parse(a['u_id']));
          }
          return timestampComparison;
        });

        setState(() {
          users = userList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load data: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  void _deleteUser(String userId) async {
    print("Deleting user with ID: $userId"); // Debugging print

    var url = Uri.parse("${Apiconst.base_url}admin_delete_user.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "u_id": userId, // Confirm key name
    });

    print("Response: ${response.body}"); // Print full API response

    var data = jsonDecode(response.body);
    if (data['error'] == false) {
      setState(() {
        users.removeWhere((item) => item['u_id'].toString() == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
    } else {
      print("Delete failed: ${data['message']}"); // Debugging print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to delete user: ${data['message']}"),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirmation(String? userId) {
    print("User ID in confirmation: $userId");

    if (userId == null || userId.isEmpty) {
      print("ERROR: User ID is null or empty!");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: const Text(
            "Confirm Deletion",
          ),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(userId);
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
          'Manage User',
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
          : users.isEmpty
              ? Center(
                  child: Text(
                    'No User\'s Available',
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
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return UserCard(
                        user: users[index],
                        onDelete: () {
                          print(
                              "User ID sent to delete: ${users[index]['u_id']}"); // Debugging print
                          _showDeleteConfirmation(
                              users[index]['u_id'].toString());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onDelete;

  const UserCard({required this.user, required this.onDelete, super.key});

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
            _buildDetailRow('Name:', user['u_name'] ?? 'N/A'),
            _buildDetailRow('Email:', user['u_email'] ?? 'N/A'),
            _buildDetailRow('Phone:', user['u_phone'] ?? 'N/A'),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['u_address'] ?? 'N/A',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    softWrap: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            _buildUserDocumentSection(user['u_documents']), // Separate Document Widget

            const SizedBox(height: 8),
            _buildDetailRow('Status:', user['u_status'] ?? 'N/A', isStatus: true),
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
                child: const Text("Delete User",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Separate Widget for Document Display**
  Widget _buildUserDocumentSection(String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700], // ✅ Works
          ),
        ),
        const SizedBox(height: 4),
        _buildUserDocumentImage(imageUrl),
      ],
    );
  }

  /// **Handles Image Display with Error & Loading State**
  Widget _buildUserDocumentImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'No document available',
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

  /// **General Row Builder for User Details**
  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          const Spacer(),
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
}

