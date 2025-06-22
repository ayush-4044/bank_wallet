import 'dart:convert';
import 'dart:io';
import 'package:bookyourev/agency/agency_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart ' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class AgencyVehicleEditpage extends StatefulWidget {
  final String? vehicleID;
  const AgencyVehicleEditpage({super.key, required this.vehicleID});

  @override
  State<AgencyVehicleEditpage> createState() => AgencyVehicleDetailpageState();
}

class AgencyVehicleDetailpageState extends State<AgencyVehicleEditpage> {
  File? _image;
  final picker = ImagePicker();
  XFile? pickedFile;
  var logindata;
  var data;
  bool isLoading = false;
  var userData;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController platenumberController = TextEditingController();

  String? selectedVehicleType; // Holds the selected dropdown value
  final _formKey = new GlobalKey<FormState>();
  String userid = "";
  var agency;
  void initState() {
    super.initState();
    getData();
  }

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('uid')!;
    });
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse("${Apiconst.base_url}agency_vehicle_details.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "a_id": prefs.getString('uid')!,
      "v_id": widget.vehicleID,
    });
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse["error"] == false) {
        var userList = jsonResponse["vehicle"];

        if (userList.isNotEmpty) {
          userData = userList[0];

          if (mounted) {
            setState(() {
              isLoading = false;
              nameController.text = userData["v_name"] ?? "";
              descriptionController.text = userData["v_description"] ?? "";
              rangeController.text = userData["v_range"] ?? "";
              speedController.text = userData["v_speed"] ?? "";
              priceController.text = userData["v_price"] ?? "";
              platenumberController.text = userData["v_number"] ?? "";
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
          "Edit Details",
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20), // Space after AppBar
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: _image != null
                                        ? Image.file(
                                            _image!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.fill,
                                          )
                                        : userData["v_photo"] != null
                                            ? Image.network(
                                                userData["v_photo"],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.fill,
                                              )
                                            : Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  left: 70,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: new BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Vehicle Image",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: nameController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Name';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.directions_car)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 7),
                            labelText: "Vehicle Name",
                            hintText: "Enter Vehicle Name",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: rangeController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Range';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null, icon: Icon(Icons.ev_station)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 7),
                            labelText: "Range",
                            hintText: "Enter Vehicle Range",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: speedController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Speed';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null, icon: Icon(Icons.speed)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 7),
                            labelText: "Speed",
                            hintText: "Enter Vehicle Speed",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: platenumberController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Number Plate';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null,
                                icon:
                                    Icon(Icons.format_list_numbered_outlined)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 7),
                            labelText: "Number Plate",
                            hintText: "Enter Vehicle Number Plate",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: priceController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Price';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.currency_rupee)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 7),
                            labelText: "Price",
                            hintText: "Enter Vehicle Price",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          controller: descriptionController,
                          maxLines: 4,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Enter Vehicle Description';
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.description_outlined)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 7),
                            labelText: "Description",
                            hintText: "Enter Vehicle Description",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        height: 70,
                        child: ElevatedButton(
                          child: Text(
                            "Submit".toUpperCase(),
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(color: Colors.green),
                              ),
                            ),
                          ),
                          onPressed: () {
                            uploadImageMedia(_image);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  uploadImageMedia(File? fileImage) async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });
    }

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse("${Apiconst.base_url}agency_update_vehicle.php"),
    );

    imageUploadRequest.headers['Cookie'] = Apiconst.cookie;
    imageUploadRequest.headers['User-Agent'] = Apiconst.user_agent;
    imageUploadRequest.fields['v_id'] = widget.vehicleID!;
    imageUploadRequest.fields['v_name'] = nameController.text;
    imageUploadRequest.fields['v_range'] = rangeController.text;
    imageUploadRequest.fields['v_speed'] = speedController.text;
    imageUploadRequest.fields['v_price'] = priceController.text;
    imageUploadRequest.fields['v_number'] = platenumberController.text;
    imageUploadRequest.fields['v_description'] = descriptionController.text;

    // **Only add the image file if it is not null**
    if (fileImage != null) {
      final mimeTypeData =
          lookupMimeType(fileImage.path, headerBytes: [0xFF, 0xD8])?.split('/');
      final file = await http.MultipartFile.fromPath(
        'v_photo',
        fileImage.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      );
      imageUploadRequest.files.add(file);
    }

    try {
      isLoading = true;

      final streamedResponse = await imageUploadRequest.send();

      streamedResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          isLoading = false;
        });

        if (streamedResponse.statusCode == 200) {
          logindata = jsonDecode(value);
          Fluttertoast.showToast(
            msg: logindata['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
          );

          if (logindata['error'] == false) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => AgencyDashboard(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Something went wrong",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
