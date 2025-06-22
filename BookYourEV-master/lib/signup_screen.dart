import 'dart:convert';
import 'dart:io';
import 'package:bookyourev/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart ' as http;
import 'CommonWidget/apiconst.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  String role = "1";
  String? _selectedOption;
  final formKey = new GlobalKey<FormState>();
  bool hideShowPassword = true;
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;
  XFile? pickedFile;
  var logindata;
  var data;
  bool isLoading = false;

  Future<void> pickImage() async {
    try {
      pickedFile = await _picker.pickImage(
        maxHeight: 250,
        maxWidth: 550,
        source: ImageSource.gallery,
      );
      setState(() {
        documentController.text = pickedFile!.path.toString();
        print(pickedFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: isLoading
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
                            Image.asset("assets/images/Register.jpg"),
                            Text("Get On Board!",
                                style: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold)),
                            Text("Create Your Profile To Start Your Journey.",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 15,
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
                                  // final nameRegex = RegExp(
                                  //   r'^(?!.*[.]{2})[a-zA-Z0-9.]{4,20}(?<![_.])$',
                                  // );
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
                              padding: EdgeInsets.only(
                                  bottom: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: hideShowPassword,
                                validator: (val) {
                                  RegExp regex = RegExp(
                                      r'^(?=.?[A-Z])(?=.?[a-z])(?=.?[0-9])(?=.?[!@#\$&*~]).{8,}$');
                                  // if (val!.isEmpty) {
                                  //   return "Please Enter Password";
                                  // } else if (!regex.hasMatch(val)) {
                                  //   return "Please Enter Valid Password";
                                  // }
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.fingerprint_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      hideShowPassword
                                          ? Icons
                                              .visibility_off // Closed eye when hidden
                                          : Icons
                                              .visibility, // Open eye when visible
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        hideShowPassword = !hideShowPassword;
                                      });
                                    },
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "Password",
                                  hintText: "Enter Your Password",
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
                            if (pickedFile != null) ...[
                              Image.file(File(
                                pickedFile!.path,
                              )),
                            ],
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: documentController,
                                readOnly: true,
                                onTap: () {
                                  pickImage();
                                },
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Upload a Valid License';
                                  }
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.document_scanner)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 7),
                                  labelText: "License",
                                  hintText: "Upload Your License",
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Role:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                ),

                                // User Radio Button
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.green,
                                      value: "1",
                                      groupValue: role,
                                      onChanged: (value) {
                                        setState(() {
                                          role = value!;
                                        });
                                      },
                                    ),
                                    Text("User"),
                                  ],
                                ),

                                // Agency Radio Button
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.green,
                                      value: "2",
                                      groupValue: role,
                                      onChanged: (value) {
                                        setState(() {
                                          role = value!;
                                        });
                                      },
                                    ),
                                    Text("Agency"),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              height: 70,
                              child: ElevatedButton(
                                  child: Text("Register".toUpperCase(),
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
                                    uploadImageMedia(File(pickedFile!.path));
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "Already Have An Account? "),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  uploadImageMedia(File fileImage) async {
    final form = formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });
    }
    final mimeTypeData =
        lookupMimeType(fileImage.path, headerBytes: [0xFF, 0xD8])?.split('/');
    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse("${Apiconst.base_url}register.php"),
    );

    final file = await http.MultipartFile.fromPath('image', fileImage.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));

    imageUploadRequest.headers['Cookie'] = Apiconst.cookie;
    imageUploadRequest.headers['User-Agent'] = Apiconst.user_agent;

    imageUploadRequest.fields['name'] = nameController.text;
    imageUploadRequest.fields['email'] = emailController.text;
    imageUploadRequest.fields['phone'] = phoneController.text;
    imageUploadRequest.fields['address'] = addressController.text;
    imageUploadRequest.fields['password'] = passwordController.text;
    imageUploadRequest.fields['role'] = role; // 1 = User, 2 = Agency
    imageUploadRequest.files.add(file);
    try {
      isLoading = true;

      final streamedResponse = await imageUploadRequest.send();

      streamedResponse.stream.transform(utf8.decoder).listen((value) {
        if (streamedResponse.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          logindata = jsonDecode(value);
          if (logindata['error'] == false) {
            Fluttertoast.showToast(
                msg: logindata['message'].toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen()),
                (Route<dynamic> route) => false);
          } else {
            Fluttertoast.showToast(
                msg: logindata['message'].toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2);
          }
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
