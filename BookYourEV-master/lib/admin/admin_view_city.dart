import 'dart:convert';
import 'package:bookyourev/admin/admin_add_city.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;
import '../CommonWidget/apiconst.dart';

class CityPage extends StatefulWidget {
  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  String? data;
  List city = [];
  var logindata;
  bool isLoading = false;
  String? cityId;

  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${Apiconst.base_url}admin_view_city.php");
    var response = await http.get(
      url,
      headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
    );

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      setState(() {
        city = decodedData["city"]?.toList() ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Failed to load data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    }
  }


  // Function to delete a city with confirmation dialog
  void _deleteCity(String cityId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: const Text('Delete City'),
          content: const Text('Are you sure you want to delete this city?'),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.black),
              ),
            ),
            // Delete Button
            TextButton(
              onPressed: () {
                _deleteCityAPI(cityId);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCityAPI(String cityId) async {
    setState(() {
      isLoading = true;
    });
    final login_url = Uri.parse("${Apiconst.base_url}admin_delete_city.php");
    final response = await http.post(login_url,
        headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
        body: {"city_id": cityId});

    print(response.body);
    if (response.statusCode == 200) {
      logindata = jsonDecode(response.body);
      print(logindata);
      setState(() {
        getData();
      });
      if (logindata['error'] == false) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: logindata['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      } else {
        Fluttertoast.showToast(
            msg: logindata['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        title: const Text(
          'Cities',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCityPage(),
                ),
              ).whenComplete(() {
                setState(() {
                  getData();
                });
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : city.isEmpty
              ? Center(
                  child: Text(
                    'No City Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // List of cities
                      Expanded(
                        child: ListView.builder(
                          itemCount: city.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Color(0xFFF5F5F5),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                title: Text(
                                  city[index]['city_name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.location_city,
                                  color: Colors.green[300],
                                  size: 30,
                                ),
                                // Delete icon button
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 28,
                                  ),
                                  onPressed: () => _deleteCity(city[index][
                                      'city_id']), // Delete city only when the delete icon is pressed
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
