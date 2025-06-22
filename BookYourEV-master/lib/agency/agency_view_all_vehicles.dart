import 'package:bookyourev/agency/agency_view_vehicle_details.dart';
import 'package:flutter/material.dart';
import 'package:bookyourev/agency/agency_add_vehicle.dart';
import 'dart:convert';
import 'package:http/http.dart ' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class AgencyVehicleScreen extends StatefulWidget {
  const AgencyVehicleScreen({super.key});

  @override
  State<AgencyVehicleScreen> createState() => AgencyVehicleScreenState();
}

class AgencyVehicleScreenState extends State<AgencyVehicleScreen> {
  String? selectedVehicleType;
  String? data;
  var category;
  var vehicle;
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
    var url = Uri.parse("${Apiconst.base_url}user_select_category.php");
    var response = await http.get(
      url,
      headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
    );
    print(response.body);
    data = response.body;
    setState(() {
      category = jsonDecode(data!)["category"];
    });
    selectedVehicleType = category[0]['cat_id'].toString();
    getVehicle(category[0]['cat_id']);
  }

  void getVehicle(String catId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${Apiconst.base_url}agency_view_vehicle.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "a_id": prefs.getString('uid')!,
      "cat_id": catId,
    });
    print(response.body);
    setState(() {
      isLoading = false;
    });
    data = response.body;
    setState(() {
      vehicle = jsonDecode(data!)["vehicle"];
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String vehicleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Vehicle"),
          backgroundColor: Color(0xFFF5F5F5),
          content: Text("Are you sure you want to delete this vehicle?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVehicle(vehicleId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(String vehicleId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse("${Apiconst.base_url}agency_delete_vehicle.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "aid": prefs.getString('uid')!,
      "vid": vehicleId,
    });
    print(response.body);
    if (response.statusCode == 200) {
      getVehicle(selectedVehicleType!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vehicle deleted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete vehicle")),
      );
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
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          "Manage Vehicle",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedVehicleType,
                      dropdownColor: Colors.white,
                      hint: Text("Select Vehicle Type"),
                      items: category.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value:
                              item['cat_id'].toString(), // Ensure it's a string
                          child: Text(item['cat_name'].toString()), // Corrected
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVehicleType = newValue;
                          print(selectedVehicleType);
                          getVehicle(selectedVehicleType!);
                        });
                        print("Selected: $newValue");
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2), // Border color when focused
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (vehicle != null) ...[
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),

                          scrollDirection: Axis.vertical, // Vertical list
                          itemCount: vehicle.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AgencyVehicledetailpage(
                                            vehicleId: vehicle[index]['v_id']),
                                  ),
                                );
                              },
                              child: Card(
                                color: Color(0xFFF5F5F5), // Light Grey

                                elevation: 5,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Left Side: Vehicle Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          vehicle[index]['v_photo'],
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Space between image & details
                                      // Right Side: Vehicle Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  vehicle[index]['v_name'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.ev_station,
                                                    size: 16),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Range ${vehicle[index]['v_range']} km",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "₹ ${vehicle[index]['v_price']} / per day",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _showDeleteConfirmationDialog(
                                                        context,
                                                        vehicle[index]['v_id']);
                                                  },
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Colors
                                                                .green
                                                                .shade500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Center(
                          child: Text("No Vehicles Available !",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AgencyVehicleFormpage()),
          ).whenComplete(() {
            getData();
          });
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        backgroundColor: Colors.green,
      ),
    );
  }
}
