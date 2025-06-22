import 'dart:convert';
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:bookyourev/user/user_3bookinghistorypage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class UserFeedbackPage extends StatefulWidget {
  final String vehicleName;
  final String vehicleID;
  final String bookingID;

  UserFeedbackPage(
      {required this.vehicleName,
      required this.bookingID,
      required this.vehicleID});

  @override
  State<UserFeedbackPage> createState() => _UserFeedbackPageState();
}

class _UserFeedbackPageState extends State<UserFeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 3.0;
  final formKey = new GlobalKey<FormState>();
  var logindata;
  var data;
  var bookingid = "";
  String userid = "";

  bool isLoading = false;

  @override
  void initState() {
    getSelectedValue();
    super.initState();
  }

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('uid')!;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookingHistoryPage()))),
        title: Text('Give FeedBack',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade300,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback for ${widget.vehicleName}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Rate your experience:'),
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.green,
                      label: _rating.toString(),
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 4,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Enter your feedback...',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: _submit,
                        child: Text(
                          'Submit Feedback',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isLoading = true;
      });

      final login_url = Uri.parse("${Apiconst.base_url}add_feedback.php");
      final response = await http.post(login_url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "uid": userid,
        "bid": widget.bookingID,
        "vid": widget.vehicleID,
        "rating": _rating.toString(),
        "comment": _feedbackController.text,
      });

      print(response.body);
      if (response.statusCode == 200) {
        logindata = jsonDecode(response.body);
        setState(() {
          isLoading = false;
        });

        if (logindata['error'] == false) {
          // Feedback successfully submitted
          Fluttertoast.showToast(
            msg: logindata['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
          );
          // Navigate back to the previous page
          Navigator.pop(context, true);
        } else {
          // If feedback already exists, show a SnackBar message
          if (logindata['message'].toString().toLowerCase().contains(
              "feedback for this booking and vehicle already exists")) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Feedback has already been submitted for this vehicle!'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: logindata['message'].toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
