import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({super.key});

  @override
  State<AgencyProfileScreen> createState() => AgencyProfileScreenState();
}

class AgencyProfileScreenState extends State<AgencyProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  var logindata;
  String userid = "";
  var data;
  var agency;
  bool isLoading = false;
  String name = "";
  void initState() {
    super.initState();
    getData();
    getSelectedValue();
  }

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('uid')!;
    });
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse("${Apiconst.base_url}agency_profile_details.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "a_id": prefs.getString('uid')!,
    });
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse["error"] == false) {
        var userList = jsonResponse["agency"];

        if (userList.isNotEmpty) {
          var userData = userList[0];

          if (mounted) {
            setState(() {
              nameController.text = userData["a_name"] ?? "";
              emailController.text = userData["a_email"] ?? "";
              phoneController.text = userData["a_phone"] ?? "";
              addressController.text = userData["a_address"] ?? "";
            });
          }
        } else {
          print("User list is empty");
        }
      } else {
        print("Error from API: ${jsonResponse['message']}");
      }
    } else {
      print("Failed to load data, status code: ${response.statusCode}");
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
          "Manage Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: isLoading == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 25, right: 25, top: 35),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color:
                                    Colors.lightGreen, // Dark blue background
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                border: Border.all(
                                  color: Colors.green, // Light blue border
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  nameController.text.isNotEmpty
                                      ? nameController.text
                                          .split(" ")[0][0]
                                          .toUpperCase()
                                      : '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: nameController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Enter a Valid Name';
                                  }
                                  ;
                                  final nameRegex = RegExp(
                                    r'^(?!.*[.]{2})[a-zA-Z0-9.]{4,20}(?<![_.])$',
                                  );
                                  if (!nameRegex.hasMatch(val)) {
                                    return 'Invalid Name.';
                                  }
                                  return null;
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.person)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "Name",
                                  hintText: "Enter Your Name",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.redAccent)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: emailController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter Email";
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(val)) {
                                    return 'Enter a Valid Email';
                                  }
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                      onPressed: null, icon: Icon(Icons.email)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "Email",
                                  hintText: "Enter Your Email",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.redAccent)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: phoneController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Enter a Valid Phone Number';
                                  }
                                  ;
                                  final phoneRegex =
                                      RegExp(r'^\+?[0-9]{10,15}$');

                                  if (!phoneRegex.hasMatch(val)) {
                                    return 'Invalid phone number';
                                  }
                                  return null;
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                      onPressed: null, icon: Icon(Icons.phone)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "Phone Number",
                                  hintText: "Enter Your Phone Number",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.redAccent)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: addressController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Enter a Valid Address';
                                  }
                                  ;
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                      onPressed: null, icon: Icon(Icons.house)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "Address",
                                  hintText: "Enter Your Address",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.redAccent)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              height: 70,
                              child: ElevatedButton(
                                  child: Text("SUBMIT",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold)),
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              side:
                                                  BorderSide(color: Colors.green)))),
                                  onPressed: () {
                                    _submit();
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });
      final login_url =
          Uri.parse("${Apiconst.base_url}agency_update_profile.php");
      final response = await http.post(login_url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "a_id": userid,
        "a_name": nameController.text,
        "a_email": emailController.text,
        "a_phone": phoneController.text,
        "a_address": addressController.text,
      });

      print(response.body);
      if (response.statusCode == 200) {
        logindata = jsonDecode(response.body);
        //data = jsonDecode(response.body)['user'];
        print(logindata);
        setState(() {
          isLoading = false;
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
  }
}
