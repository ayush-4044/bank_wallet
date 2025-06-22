import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        title: Text(
          "TERMS & CONDITIONS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("1. GENERAL"),
            bulletPoint(
                "These terms & conditions are applied to a user who has access to avail the services provided by Book Your Ev."),
            bulletPoint(
                "These will regulate & govern the relationship between Book Your Ev and \"User\"."),
            bulletPoint(
                "Book Your Ev and \"User\" are hereinafter collectively referred to as \"Parties\" and individually as \"Party\"."),
            bulletPoint(
                "These terms & conditions shall constitute a legally valid & binding contract under the applicable laws."),
            bulletPoint(
                "Use of any service through Book Your Ev’s App by the user shall be deemed to be an acceptance of all terms and conditions set forth here in."),
            sectionTitle("2. USER REGISTRATION"),
            bulletPoint(
                "In order to avail the Services offered by Book Your Ev, the user shall be required to complete the Registration process through its official App."),
            bulletPoint(
                "User registration must satisfy the eligibility criteria & be supported by all the necessary documentation mentioned under ANNEXURE B."),
            bulletPoint(
                "Registration acceptance is subject to approval by Book Your Ev at its sole discretion."),
            bulletPoint(
                "Book Your Ev reserves all the rights to verify the authenticity of the documents provided by the applicant at any point of time."),
            sectionTitle("3. BOOKING"),
            bulletPoint(
                "The user is required to book the vehicle or service strictly through the Book Your Ev Mobile App."),
            bulletPoint(
                "The booking made shall be made and honored by the registered user only."),
            bulletPoint("The booking shall be strictly non-transferable."),
            bulletPoint(
                "The booking shall be made and honored as per the available inventory."),
            bulletPoint(
                "The booking shall be open to change as per the availability of the inventory vehicles."),
            sectionTitle("4. Vehicle Pick-Up & Return"),
            bulletPoint(
                "Book Your Ev shall notify the pick-up and drop location of the vehicle through the Mobile App."),
            bulletPoint(
                "The User shall furnish a valid Government ID proof before taking the delivery of the vehicle."),
            bulletPoint(
                "The User shall dutifully pick up the vehicle from the designated location."),
            bulletPoint(
                "The User shall inspect the vehicle for any signs of damage or malfunction and inform BYE if any irregularities are observed."),
            bulletPoint(
                "Book Your Ev shall initiate the ride/booking start time as soon as the physical possession of the vehicle has been transferred to the User."),
            bulletPoint(
                "The User shall return the vehicle to the same location as designated by Book Your Ev."),
            bulletPoint(
                "The User shall return the vehicle in the same condition it was received."),
            bulletPoint(
                "A thorough inspection of the vehicle shall be conducted before receiving the vehicle at the drop location."),
            sectionTitle("5. Deposit Amount"),
            bulletPoint("The deposit amount is 2x to rental amount"),
            bulletPoint(
                "You have to pay compulsory deposit amount before booking."),
            bulletPoint(
                "Deposit amount returned to you after you return the vehicle."),
            bulletPoint(
                "If the vehicle had any issue then the amount will be deduct from your deposit amount."),
            sectionTitle("6. Cancel Booking"),
            bulletPoint("Cancel the booking before the start date."),
            bulletPoint(
                "If you cancel the booking at the start day then 30% rent amount you have to pay to the agency."),
            bulletPoint(
                "Cancellation policy and charges is applied to as per the agency's terms & conditions."),
            sectionTitle("7.Charging"),
            bulletPoint("We provide you 100% charged vehicle."),
            bulletPoint("We will Provide You Charger along with the vehicle"),
            bulletPoint("If you ride more kilometers and charging is zero than you have to charge the vehicle yourself its your responsibility to charge the vehicle before battery is dead."),
            bulletPoint("When you return the vehicle to the agency it must be minimum 20% is charged or more."),
            sectionTitle(
                "ANNEXURE B - ELIGIBILITY CRITERIA AND SUPPORTING DOCUMENTS"),
            sectionSubtitle("Eligibility Criteria:"),
            bulletPoint(
                "Users must be above the age of 18 (20 years of age in respect of certain categories of Vehicles)."),
            bulletPoint(
                "Users must possess a valid driver's license (two-wheeler) issued by the Government of India."),
            bulletPoint(
                "Users must possess sufficient identity, age, and address proof."),
            sectionSubtitle("Supporting Documents:"),
            bulletPoint("Proof of Identity."),
            bulletPoint("Proof of Age."),
            bulletPoint("Proof of Permanent Address."),
            bulletPoint("A valid Driver’s License to operate the Vehicle."),
            bulletPoint("Recent color photographs (Selfie)."),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        subtitle,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
