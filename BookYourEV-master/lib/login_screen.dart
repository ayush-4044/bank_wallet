import 'dart:convert';
import 'package:bookyourev/CommonWidget/apiconst.dart';
import 'package:bookyourev/admin/admin_dashboard.dart';
import 'package:bookyourev/select_citypage.dart';
import 'package:bookyourev/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart ' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool hideShowPassword = true;
  var logindata;
  var data;
  bool isLoading = false;

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
                            Image.asset("assets/images/Login.png"),
                            Text("Welcome Back!",
                                style: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold)),
                            Text("Make It Work, Make It Right, Make It Fast.",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: emailController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter Your Email";
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
                              height: 18,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: 10, left: 10, right: 10),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: hideShowPassword,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter Your Password";
                                  }
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
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              height: 70,
                              child: ElevatedButton(
                                  child: Text("Login".toUpperCase(),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "Don't Have An Account? "),
                          TextSpan(
                            text: 'Sign Up',
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

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });
      final login_url = Uri.parse("${Apiconst.base_url}checklogin.php");
      final response = await http.post(login_url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "email": emailController.text,
        "password": passwordController.text
      });

      print(response.body);
      if (response.statusCode == 200) {
        logindata = jsonDecode(response.body);
        data = jsonDecode(response.body)['user'];
        print(logindata);
        setState(() {
          isLoading = false;
        });
        if (logindata['error'] == false) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectCityPage()));
          SharedPreferences setpreference =
              await SharedPreferences.getInstance();
          setpreference.setString('uid', data['uid'].toString());
          setpreference.setString('uname', data['uname'].toString());
          setpreference.setString('urole', data['urole'].toString());
          if (data["urole"] == "1") {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => SelectCityPage()),
                (Route<dynamic> route) => false);
          } else if (data["urole"] == "0") {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => AdminDashboardPage()),
                (Route<dynamic> route) => false);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => SelectCityPage()),
                (Route<dynamic> route) => false);
          }
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
