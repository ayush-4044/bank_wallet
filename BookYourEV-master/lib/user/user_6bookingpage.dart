import 'dart:convert';
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:bookyourev/user/user_7creditcardpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart ' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class BookingScreen extends StatefulWidget {
  final String? vehicleId;
  final String vehicleRent;
  BookingScreen({required this.vehicleRent, required this.vehicleId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  String? selectedPaymentMethod;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final formKey = new GlobalKey<FormState>();
  var logindata;
  var data;
  bool isLoading = false;
  String userid = "";
  int days = 0;
  int rentAmount = 0;
  int securityDeposit = 0;
  int totalPayment = 0;

  @override
  void initState() {
    getSelectedValue();
    super.initState();
  }

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      days = _calculateDays();
      rentAmount = (int.parse(widget.vehicleRent)) * days;
      securityDeposit = (int.parse(widget.vehicleRent)) * 2;
      totalPayment = _calculateTotalPayment();
      userid = prefs.getString('uid')!;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green, // Header background color
            hintColor: Colors.black, // Calendar days color
            colorScheme: ColorScheme.light(
              primary: Colors.green, // Selected date color
              onPrimary: Colors.white, // Text color on selected date
              onSurface: Colors.black, // Text color on unselected dates
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isCheckIn) {
        if (checkOutDate != null && picked.isAfter(checkOutDate!)) {
          _showError("Start date cannot be after end date.");
          return;
        }
        setState(() {
          checkInDate = picked;
          checkOutDate = null;
        });
      } else {
        if (checkInDate == null) {
          _showError("Please select a start date first.");
          return;
        }
        if (picked.isBefore(checkInDate!)) {
          _showError("End date cannot be before start date.");
          return;
        }
        setState(() {
          checkOutDate = picked;
        });
      }

      // Recalculate and update prices
      setState(() {
        days = _calculateDays();
        rentAmount = int.parse(widget.vehicleRent) * days;
        securityDeposit = int.parse(widget.vehicleRent) * 2;
        totalPayment = _calculateTotalPayment();
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green, // Header background color
            hintColor: Colors.black, // Hint text color
            colorScheme: ColorScheme.light(
              primary: Colors.green, // Selected time color
              onPrimary: Colors.white, // Text color on selected time
              onSurface: Colors.black, // Text color on unselected times
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // OK and Cancel buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        if (isCheckIn) {
          checkInTime = picked;
        } else {
          checkOutTime = picked;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _validateAndShowPaymentDialog() {
    if (checkInDate == null) {
      _showError("Please select a start date.");
      return;
    }
    if (checkOutDate == null) {
      _showError("Please select an end date.");
      return;
    }
    if (checkInTime == null) {
      _showError("Please select a start time.");
      return;
    }
    if (checkOutTime == null) {
      _showError("Please select an end time.");
      return;
    }
    _showPaymentDialog();
  }

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Method",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  _buildPaymentOption(
                    "Debit Card",
                    "debit_card",
                    setModalState,
                  ),
                  _buildPaymentOption(
                    "Visa",
                    "visa",
                    setModalState,
                  ),
                  _buildPaymentOption(
                    "Cash on Delivery",
                    "cash_on_delivery",
                    setModalState,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (selectedPaymentMethod == "cash_on_delivery") {
                        Navigator.pop(context);
                        _submit();
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreditCardPage(
                                      vehicleId: widget.vehicleId,
                                      userid: userid,
                                      enddate: DateFormat('yyyy-MM-dd')
                                          .format(checkOutDate!),
                                      endtime:
                                          '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}',
                                      startdate: DateFormat('yyyy-MM-dd')
                                          .format(checkInDate!),
                                      starttime:
                                          '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}',
                                      totalamount: totalPayment.toString(),
                                    )));
                      }
                    },
                    child: Text(
                      "Confirm and pay",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 16),
              Text("Booking Successful!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserDashboardPage()),
                    (Route<dynamic> route) => false, // Remove all routes
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
      String label, String value, StateSetter setModalState) {
    return ListTile(
      leading: value == "debit_card"
          ? Icon(Icons.add_circle_outline, color: Colors.green)
          : value == "cash_on_delivery"
              ? Icon(Icons.money, color: Colors.green)
              : Icon(Icons.credit_card, color: Colors.green),
      title: Text(label),
      trailing: Radio<String>(
        activeColor: Colors.green,
        value: value,
        groupValue: selectedPaymentMethod,
        onChanged: (String? newValue) {
          setModalState(() {
            selectedPaymentMethod = newValue;
          });
        },
      ),
    );
  }

  int _calculateDays() {
    if (checkInDate != null && checkOutDate != null) {
      int difference = checkOutDate!.difference(checkInDate!).inDays + 1;
      return difference > 0 ? difference : 1;
    }
    return 1; // Default to 1 day if no selection is made
  }

  int _calculateTotalPayment() {
    int days = _calculateDays();
    int rentAmount = int.parse(widget.vehicleRent) * days;
    int securityDeposit = int.parse(widget.vehicleRent) * 2;
    return rentAmount + securityDeposit;
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
        backgroundColor: Colors.green.shade300,
        title: Text(
          "Request to Book",
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date & Time",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildDateTimeSelector(
                                "Start", checkInDate, checkInTime, true)),
                        SizedBox(width: 10),
                        Expanded(
                            child: _buildDateTimeSelector(
                                "End", checkOutDate, checkOutTime, false)),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildPaymentDetails(),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: _validateAndShowPaymentDialog,
                      child: Text(
                        "Select Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
      final login_url = Uri.parse("${Apiconst.base_url}add_booking.php");
      final response = await http.post(login_url, headers: {
        'cookie': Apiconst.cookie,
        'User-Agent': Apiconst.user_agent
      }, body: {
        "vid": widget.vehicleId,
        "uid": userid,
        "startdate": DateFormat('yyyy-MM-dd').format(checkInDate!),
        "starttime":
            '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}',
        "enddate": DateFormat('yyyy-MM-dd').format(checkOutDate!),
        "endtime":
            '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}',
        "paymentmode": selectedPaymentMethod == "debit_card"
            ? "1"
            : selectedPaymentMethod == "cash_on_delivery"
                ? "2"
                : "3",
        "totalamount": totalPayment.toString(),
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
          _showSuccessAlert();
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

  Widget _buildDateTimeSelector(
      String label, DateTime? date, TimeOfDay? time, bool isCheckIn) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectDate(context, isCheckIn),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_today, size: 20),
                SizedBox(height: 5),
                Text("$label Date",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(
                  date != null
                      ? DateFormat("MMM dd, yyyy").format(date)
                      : "Select Date",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => _selectTime(context, isCheckIn),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(Icons.access_time, size: 20),
                SizedBox(height: 5),
                Text("$label Time",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(
                  time != null ? time.format(context) : "Select Time",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Details", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildPriceRow("Rent ($days days)", "${rentAmount} Rs"),
        _buildPriceRow("Security Deposit", "${securityDeposit} Rs"),
        Divider(),
        _buildPriceRow("Total Payment", "${totalPayment} Rs", isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(price,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
