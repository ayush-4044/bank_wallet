import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../CommonWidget/apiconst.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  String? selectedVehicleType;
  List<dynamic> category = [];
  bool isLoading = true;
  List<dynamic> vehicle = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      var url = Uri.parse("${Apiconst.base_url}user_select_category.php");
      var response = await http.get(
        url,
        headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
      );
print(response.body);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          category = responseData["category"] ?? [];
          isLoading = false;
          if (category.isNotEmpty) {
            selectedVehicleType = category[0]['cat_id'].toString();
            _getVehicle(category[0]['cat_id']);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getVehicle(String catId) async {
    setState(() {
      isLoading = true;
      vehicle.clear(); // Clear old data
    });

    try {
      var url = Uri.parse("${Apiconst.base_url}admin_view_vehicle.php");
      var response = await http.post(url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "cat_id": catId,
      });

      print("Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var data = jsonDecode(response.body);
        List<dynamic> fetchedVehicles = data["vehicle"] ?? [];

        print("Fetched Vehicles: $fetchedVehicles"); // Debugging

        // Sorting by `v_id` (newest first)
        fetchedVehicles.sort((a, b) {
          int idA = int.tryParse(a["v_id"].toString()) ?? 0;
          int idB = int.tryParse(b["v_id"].toString()) ?? 0;
          return idB.compareTo(idA); // Descending order (newest first)
        });

        setState(() {
          vehicle = fetchedVehicles;
          isLoading = false;
        });

        print("Sorted Vehicles: $vehicle"); // Debugging
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No vehicles available for the selected category."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load vehicles. Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }




  void _deleteVehicle(String vehicleId) async {
    var url = Uri.parse("${Apiconst.base_url}admin_delete_vehicle.php");
    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "v_id": vehicleId,
    });

    var data = jsonDecode(response.body);
    if (data['error'] == false) {
      setState(() {
        vehicle.removeWhere((v) => v['v_id'].toString() == vehicleId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vehicle deleted successfully"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete vehicle"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(String vehicleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: const Text("Delete Vehicle"),
          content: const Text("Are you sure you want to delete this vehicle?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVehicle(vehicleId);
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
        title: const Text(
          'Vehicle History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : category.isEmpty
              ? const Center(child: Text("No categories available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedVehicleType,
                        items: category.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['cat_id'].toString(),
                            child: Text(item['cat_name'].toString()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue;
                            _getVehicle(selectedVehicleType!);
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: vehicle.isEmpty
                            ? const Center(
                                child: Text(
                                  "For this category, vehicles are not available.",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: vehicle.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: Color(0xFFF5F5F5),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          vehicle[index]['v_photo'] != null
                                              ? Image.network(
                                                  vehicle[index]['v_photo'],
                                                  width: double.infinity,
                                                  height: 280,
                                                  fit: BoxFit.fill,
                                                )
                                              : const SizedBox.shrink(),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Vehicle: ${vehicle[index]['v_name']}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    "Agency: ${vehicle[index]['a_name']}"),
                                                Text(
                                                    "City: ${vehicle[index]['city_name']}"),
                                                Text(
                                                    "Number: ${vehicle[index]['v_number']}"),
                                                Text(
                                                    "Speed: ${vehicle[index]['v_speed']} km/h"),
                                                Text(
                                                    "Range: ${vehicle[index]['v_range']} km"),
                                                Text(
                                                    "Price: ₹${vehicle[index]['v_price']}"),
                                                SizedBox(
                                                  width: double.infinity, // Ensure it takes full width
                                                  child: Text(
                                                    "Description: ${vehicle[index]['v_description']}",
                                                    style: const TextStyle(fontSize: 14),
                                                    maxLines: null, // Allow unlimited lines
                                                    overflow: TextOverflow.visible, // Make sure text is fully shown
                                                  ),
                                                ),

                                                const SizedBox(height: 10),
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                            vehicle[index]['v_id']
                                                                .toString()),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                    ),
                                                    child: const Text(
                                                      "Delete Vehicle",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                ),
    );
  }
}
