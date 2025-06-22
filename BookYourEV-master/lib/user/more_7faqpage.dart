import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'title': 'What is Book Your Ev?',
      'subtitle':
          'Book Your Ev is a platform to rent or book electric vehicles for your needs.',
    },
    {
      'title': 'How do I book an Ev?',
      'subtitle':
          'You can browse available Evs, select the one you like, and book it in just a few clicks.',
    },
    {
      'title': 'Are there any discounts?',
      'subtitle':
          'Yes! We offer regular discounts and cashback offers. Check the Offers section for details.',
    },
    {
      'title': 'Is there customer support?',
      'subtitle':
          'Yes, 24/7 customer support is available to help you with your bookings.',
    },
    {
      'title': 'Can I cancel a booking?',
      'subtitle':
          'Yes, bookings can be canceled based on our cancellation policy.',
    },
  ];

  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(faqs.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        title: Text("FAQ'S",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Card(
              color: Color(0xFFF5F5F5),
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: faqs.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, String> faq = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded[index] = !_isExpanded[index];
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  faq['title']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                _isExpanded[index]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        AnimatedCrossFade(
                          firstChild: Text(
                            faq['subtitle']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            faq['subtitle']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          crossFadeState: _isExpanded[index]
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 200),
                        ),
                        SizedBox(height: 8),
                        if (index != faqs.length - 1)
                          Divider(color: Colors.grey[300], thickness: 1),
                        SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
