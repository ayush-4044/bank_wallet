import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bookyourev/CommonWidget/apiconst.dart';
import 'agency_edit_vehicle_details.dart';

class AgencyVehicledetailpage extends StatefulWidget {
  final String? vehicleId;
  const AgencyVehicledetailpage({Key? key, required this.vehicleId})
      : super(key: key);

  @override
  State<AgencyVehicledetailpage> createState() => _VehicledetailpageState();
}

class _VehicledetailpageState extends State<AgencyVehicledetailpage> {
  bool isLoading = false;
  String? data;
  var vehicle;
  bool _isChecked = false; // Checkbox state

  void getVehicle() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${Apiconst.base_url}user_view_vehiclealldetails.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "v_id": widget.vehicleId,
    });

    print(response.body);

    setState(() {
      isLoading = false;
      data = response.body;
      vehicle = jsonDecode(data!)["vehicle"];
    });
  }

  @override
  void initState() {
    getVehicle();
    super.initState();
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
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          vehicle == null ? "" : vehicle[0]['v_name'],
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
                    // Vehicle Image
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(25),top:Radius.circular(25)),
                            image: DecorationImage(
                              image: NetworkImage(vehicle[0]['v_photo']),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Specifications
                    Text(
                      "Specifications",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _specCard("Max. Speed", "${vehicle[0]['v_speed']}km/h"),
                        _specCard("Range", "${vehicle[0]['v_range']}km"),
                        _specCard("Number", vehicle[0]['v_number']),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Description
                    Text(
                      "Description",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(vehicle[0]['v_description']),
                    SizedBox(height: 10),

                    // Rent Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rent",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${vehicle[0]['v_price']} ₹/Day",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            ElevatedButton(
              child: Text(
                "Edit Details",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                if (widget.vehicleId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgencyVehicleEditpage(
                        vehicleID: widget.vehicleId!,
                      ),
                    ),
                  );
                } else {
                  // Handle the null case (e.g., show an error)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vehicle ID is missing")),
                  );
                }
              },
              // Disable button if not checked
            ),
          ],
        ),
      ),
    );
  }

  Widget _specCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: myBoxDecoration(),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}
