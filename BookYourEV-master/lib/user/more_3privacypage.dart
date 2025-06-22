import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        title: Text('PRIVACY POLICY',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PRIVACY POLICY'),
              _buildParagraph(
                  "We have established this Privacy Policy to let you know the kinds of information we may gather during your use of the Services and related other Interactions, how we use your information, when we might disclose your information, and your rights and choices regarding your information that we collect and process."),
              _buildParagraph(
                  "Book Your EV is a wholly owned and controlled enterprise of Hero MotoCorp Limited. Book Your EV name and its logo are registered trademark of Hero MotoCorp Limited."),
              _buildSectionTitle('GOVERNING LAW'),
              _buildParagraph(
                  "For any of the concerns and actions for or against us regarding this Privacy Policy it will be governed under Indian law. In case of any dispute between the parties, the courts of New Delhi shall have exclusive jurisdiction over any dispute arising out of or in connection with this agreement."),
              _buildSectionTitle('THE INFORMATION WE COLLECT'),
              _buildParagraph(
                  "We collect information related to our Services and Interactions directly from users, automatically related to their use of the Services, its various features and our Interactions, as well as from third parties. We may combine the information we collect from the following mentioned sources."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
