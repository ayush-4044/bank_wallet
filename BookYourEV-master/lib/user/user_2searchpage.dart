import 'dart:convert';
import 'package:http/http.dart ' as http;
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:bookyourev/user/user_5vehicledetailpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  int selectedCategoryIndex = 0;
  bool isLoading = false;
  String? data;
  String? catID;
  var vehicle;
  var category;
  String currentCity = '';

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCity = prefs.getString('selectedCity')!;
    });
  }

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
      catID = category[0]['cat_id'];
    });
    getVehicle(category[0]['cat_id']);
  }

  void getVehicle(String catId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${Apiconst.base_url}user_view_vehicle.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "city_id": prefs.getString('city_id')!,
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

  void getSearchVehicle(String vehicleName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${Apiconst.base_url}user_search_vehicle.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "city_id": prefs.getString('city_id')!,
      "cat_id": catID,
      "v_name": vehicleName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserDashboardPage()))),
        backgroundColor: Colors.green.shade300,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            cursorColor: Colors.grey,
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for EVs...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              getSearchVehicle(searchController.text);
                            });
                            // Handle search logic here
                          },
                          child: Text('Search',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.green.shade500),
                          ),
                        ),
                      ],
                    ),
                    // Category Buttons
                    SizedBox(height: 10),
                    Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                                catID = category[index]['cat_id'];
                                getVehicle(category[index]['cat_id']);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedCategoryIndex == index
                                    ? Colors.green
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  category[index]['cat_name'],
                                  style: TextStyle(
                                    color: selectedCategoryIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Vehicle List
                    SizedBox(height: 10),

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
                                    builder: (context) => Vehicledetailpage(
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
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Vehicledetailpage(
                                                                  vehicleId: vehicle[
                                                                          index]
                                                                      [
                                                                      'v_id'])),
                                                    );
                                                  },
                                                  child: Text("BOOK NOW",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold)),
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
                          child: Text("No vehicles available",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
