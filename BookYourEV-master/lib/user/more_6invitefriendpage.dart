import 'package:flutter/material.dart';

class InviteFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green.shade300,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("INVITE YOUR FRIENDS",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset("assets/images/refer_friend.jpg"),
                    Text("Invite your friend, Enjoy the Ride",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                        "Share below code with your friends and social network connections."),
                    SizedBox(height: 20),
                    Text("REFERRAL CODE",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text("Tap to Copy", textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 10),
                    Text("https://bookyourev.page.link/Axxf"),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Invite Friend",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green.shade500),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("REDEEM CODE",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your code e.g. 5623x6",
                        suffixIcon: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
