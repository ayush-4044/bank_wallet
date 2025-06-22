import 'dart:convert';
import 'package:bookyourev/CommonWidget/apiconst.dart';
import 'package:bookyourev/agency/agency_dashboard.dart';
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart ' as http;

class SelectCityPage extends StatefulWidget {
  @override
  _SelectCityPageState createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  String? data;
  var city;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var url = Uri.parse("${Apiconst.base_url}user_select_city.php");
    var response = await http.get(
      url,
      headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
    );
    print(response.body);
    data = response.body;
    setState(() {
      city = jsonDecode(data!)["city"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Please Select Your City',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: city == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Cities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: city.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            SharedPreferences setpreference =
                                await SharedPreferences.getInstance();
                            setpreference.setString(
                                'selectedCity', city[index]['city_name']);
                            setpreference.setString(
                                'city_id', city[index]['city_id']);
                            setState(() {
                              selectedCity = city[index]['city_name'];
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getString('urole') != null &&
                                prefs.getString('urole') == "2") {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AgencyDashboard()),
                                  (Route<dynamic> route) => false);
                            } else if (prefs.getString('urole') != null &&
                                prefs.getString('urole') == "1") {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          UserDashboardPage()),
                                  (Route<dynamic> route) => false);
                            }
                          },
                          child: Card(
                            color: Color(0xFFF5F5F5), // Light Grey
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_city,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  city[index]['city_name'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  /* if (selectedCity != null) ...[
              const SizedBox(height: 20),
              Text(
                'Selected City: $selectedCity',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ]*/
                ],
              ),
            ),
    );
  }
}
