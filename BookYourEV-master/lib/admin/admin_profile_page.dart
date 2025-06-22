import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool hideShowPassword = true;
  String userid = "";
  var data;
  var logindata;
  var user;
  bool isLoading = false;
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
    String? userId = prefs.getString('uid');

    print("Admin User ID: $userId"); // Debugging line

    if (userId == null || userId.isEmpty) {
      print("User ID is null or empty.");
      return;
    }

    var url = Uri.parse("${Apiconst.base_url}user_profile_details.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "u_id": userId,
    });

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse["error"] == false) {
        var userList = jsonResponse["user"];

        if (userList.isNotEmpty) {
          var userData = userList[0]; // Extract first user
          setState(() {
            nameController.text = userData["u_name"] ?? "";
            emailController.text = userData["u_email"] ?? "";
            phoneController.text = userData["u_phone"] ?? "";
            addressController.text = userData["u_address"] ?? "";
          });
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
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Manage Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.green),
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
                                  // if (!nameRegex.hasMatch(val)) {
                                  //   return 'Invalid Name.';
                                  // }
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
                                      onPressed: null, icon: Icon(Icons.home)),
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
                                  child: Text("Submit",
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
          Uri.parse("${Apiconst.base_url}user_update_profile.php");
      final response = await http.post(login_url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "u_id": userid,
        "u_name": nameController.text,
        "u_email": emailController.text,
        "u_phone": phoneController.text,
        "u_address": addressController.text,
      });

      print(response.body);
      if (response.statusCode == 200) {
        logindata = jsonDecode(response.body);
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
