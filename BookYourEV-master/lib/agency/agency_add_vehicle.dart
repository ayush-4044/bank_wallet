import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart ' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class AgencyVehicleFormpage extends StatefulWidget {
  const AgencyVehicleFormpage({super.key});

  @override
  State<AgencyVehicleFormpage> createState() => AgencyVehicleFormpageState();
}

class AgencyVehicleFormpageState extends State<AgencyVehicleFormpage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  var vehicledata;
  bool isLoading = false;
  String? data;
  var category;
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
    setState(() {
      isLoading = false;
    });
    data = response.body;
    setState(() {
      category = jsonDecode(data!)["category"];
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController platenumberController = TextEditingController();

  String? selectedVehicleType; // Holds the selected dropdown value

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
          "Add Vehicle",
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
                      DropdownButtonFormField<String>(
                        value: selectedVehicleType,
                        dropdownColor: Colors.white,
                        hint: Text("Select Vehicle Type"),
                        items: category.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['cat_id']
                                .toString(), // Ensure it's a string
                            child:
                                Text(item['cat_name'].toString()), // Corrected
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue;
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
                      SizedBox(height: 20), // Space after AppBar
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
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
                                  : Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Upload Vehicle Image",
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
                            uploadImageMedia(_image!);
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

  uploadImageMedia(File fileImage) async {
    final form = _formKey.currentState;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });
    }
    final mimeTypeData =
        lookupMimeType(fileImage.path, headerBytes: [0xFF, 0xD8])?.split('/');
    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse("${Apiconst.base_url}add_vehicle.php"),
    );

    final file = await http.MultipartFile.fromPath('photo', fileImage.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));

    imageUploadRequest.headers['Cookie'] = Apiconst.cookie;
    imageUploadRequest.headers['User-Agent'] = Apiconst.user_agent;

    imageUploadRequest.fields['aid'] = prefs.getString('uid')!;
    imageUploadRequest.fields['catid'] = selectedVehicleType!;
    imageUploadRequest.fields['cityid'] = prefs.getString('city_id')!;
    imageUploadRequest.fields['name'] = nameController.text;
    imageUploadRequest.fields['description'] = descriptionController.text;
    imageUploadRequest.fields['speed'] = speedController.text;
    imageUploadRequest.fields['range'] = rangeController.text;
    imageUploadRequest.fields['price'] = priceController.text;
    imageUploadRequest.fields['number'] = platenumberController.text;
    imageUploadRequest.files.add(file);
    try {
      isLoading = true;

      final streamedResponse = await imageUploadRequest.send();

      streamedResponse.stream.transform(utf8.decoder).listen((value) {
        if (streamedResponse.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          vehicledata = jsonDecode(value);
          if (vehicledata['error'] == false) {
            Fluttertoast.showToast(
                msg: vehicledata['message'].toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2);
            Navigator.of(context).pop();
          } else {
            Fluttertoast.showToast(
                msg: vehicledata['message'].toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2);
          }
          Fluttertoast.showToast(
              msg: "Successfully",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2);
          print(streamedResponse.stream);
          print(value);
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Something went wrong",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2);
          print(value);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
