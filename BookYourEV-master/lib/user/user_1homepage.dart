import 'dart:convert';
import 'package:http/http.dart ' as http;
import 'package:bookyourev/user/user_5vehicledetailpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';
import '../select_citypage.dart';

class Homepage extends StatefulWidget {
  final VoidCallback onSeeAllTap;

  const Homepage({Key? key, required this.onSeeAllTap}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedCategoryIndex = 0;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = false;

  final List<String> sliderImages = [
    'assets/images/Dash1.webp',
    'assets/images/Dash2.png',
    'assets/images/Dash3.png',
    'assets/images/Dash4.png',
  ];

  final List<Map<String, String>> titlesAndSubtitles = [
    {
      'title': 'Electric Vehicles',
      'subtitle': 'Explore a range of eco-friendly vehicles.',
    },
    {
      'title': 'Affordable Pricing',
      'subtitle': 'Great deals for your ride, at unbeatable prices.',
    },
    {
      'title': 'Eco-friendly',
      'subtitle': 'Join the green revolution with sustainable choices.',
    },
    {
      'title': 'User-friendly',
      'subtitle': 'Easy-to-use app for seamless booking experience.',
    },
    {
      'title': 'Customer Support',
      'subtitle': '24/7 support to help you every step of the way.',
    },
  ];
  List<Map<String, String>> offers = [
    {
      'title': 'Exclusive Discounts',
      'subtitle': 'Save big on your favorite EVs.',
    },
    {
      'title': 'Special Rewards',
      'subtitle': 'Earn rewards on every booking.',
    },
    {
      'title': 'Limited Time Offers',
      'subtitle': 'Grab exciting deals before they’re gone!',
    },
    {
      'title': 'Latest EV Deals',
      'subtitle': 'Check out the newest deals for EVs.',
    },
    {
      'title': 'Cashback Offers',
      'subtitle': 'Get cashback on your bookings.',
    },
  ];
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

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % sliderImages.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(seconds: 5),
          curve: Curves.ease,
        );
        _autoScroll();
      }
    });
  }

  String? data;
  var category;
  var vehicle;
  String currentCity = '';

  getSelectedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCity = prefs.getString('selectedCity')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getSelectedValue();
    _autoScroll();
    _isExpanded = List<bool>.filled(faqs.length, false);
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
    data = response.body;
    setState(() {
      category = jsonDecode(data!)["category"];
    });
    getVehicle(category[0]['cat_id']);
  }

  void getVehicle(String catId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${Apiconst.base_url}user_view_vehicle.php");

    var response = await http.post(url, headers: {
      'cookie': Apiconst.cookie,
      'User-Agent': Apiconst.user_agent
    }, body: {
      "city_id": prefs.getString('city_id')!,
      "cat_id": catId,
    });
    print(response.body);
    setState(() {
      isLoading = false;
    });
    data = response.body;
    setState(() {
      vehicle = jsonDecode(data!)["vehicle"];
    });
  }

  Widget buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 180.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderImages.length,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: AssetImage(sliderImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sliderImages.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _pageController.animateToPage(entry.key,
                    duration: Duration(milliseconds: 100), curve: Curves.ease),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.green)
                          .withOpacity(_currentPage == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade300,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  currentCity,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Book Your EV',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildImageSlider(),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Existing City Name
                            Text(
                              'Current City: $currentCity', // Replace with dynamic city name if needed
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: 8.0),

                            // Prompt for Booking in a Different City
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectCityPage()));
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Want To Book In Different City?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                  getVehicle(category[index]['cat_id']);
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selectedCategoryIndex == index
                                      ? Colors.green[500]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    category[index]['cat_name'],
                                    style: TextStyle(
                                      color: selectedCategoryIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Ev\'s',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: widget.onSeeAllTap,
                            child: Text('See All',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green.shade500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (vehicle != null) ...[
                        Container(
                          height: 365,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vehicle.length > 2 ? 2 : vehicle.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Vehicledetailpage(
                                          vehicleId: vehicle[index]['v_id']),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Color(0xFFF5F5F5), // Light Grey
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    width: 270,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.network(
                                            vehicle[index]['v_photo'],
                                            height: 200,
                                            width: 250,
                                            fit: BoxFit.fill,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            vehicle[index]['v_name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.ev_station),
                                                  Text(
                                                    "${vehicle[index]['v_range']} km",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "₹ ${vehicle[index]['v_price']} / per day",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Vehicledetailpage(
                                                            vehicleId:
                                                                vehicle[index]
                                                                    ['v_id'])),
                                              );
                                            },
                                            child: Text("BOOK NOW",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.green.shade500),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Center(
                            child: Text("No vehicles available",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                      ],
                      SizedBox(height: 20),
                      Text(
                        "Why Book Your Ev",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 85, // Adjust height for horizontal layout
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: titlesAndSubtitles.length,
                          itemBuilder: (context, index) {
                            // Define icons for each offer card
                            List<IconData> offerIcons = [
                              Icons.electric_car,
                              Icons.attach_money,
                              Icons.eco,
                              Icons.touch_app,
                              Icons.support_agent,
                            ];

                            return Card(
                              color: Color(0xFFF5F5F5), // Light Grey
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 280, // Fixed width for horizontal layout
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center horizontally
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Center vertically
                                  children: [
                                    // CircleAvatar with an icon
                                    CircleAvatar(
                                      backgroundColor: Colors.green.shade400,
                                      radius: 24,
                                      child: Icon(
                                        offerIcons[index],
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Title and Subtitle
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Center vertically
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            titlesAndSubtitles[index]['title']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Subtitle (two-line text)
                                          Text(
                                            titlesAndSubtitles[index]['subtitle']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Offers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 85, // Adjust height for horizontal layout
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            // Define icons for each offer card
                            List<IconData> offerIcons = [
                              Icons.local_offer, // For "Exclusive Discounts"
                              Icons.card_giftcard, // For "Special Rewards"
                              Icons.flash_on, // For "Limited Time Offers"
                              Icons.new_releases, // For "Latest EV Deals"
                              Icons.percent, // For "Cashback Offers"
                            ];

                            // Title and subtitle for each offer

                            return Card(
                              color: Color(0xFFF5F5F5), // Light Grey
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 280, // Fixed width for horizontal layout
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // CircleAvatar with an icon
                                    CircleAvatar(
                                      backgroundColor: Colors.green.shade400,
                                      radius: 24,
                                      child: Icon(
                                        offerIcons[
                                            index], // Icon for the specific offer
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Title and Subtitle
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            offers[index]['title']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Subtitle (two-line text)
                                          Text(
                                            offers[index]['subtitle']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "FAQs",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Card(
                        color: Color(0xFFF5F5F5), // Light Grey
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // List of FAQs
                              ...faqs.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, String> faq = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // FAQ Title with Arrow Icon
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isExpanded[index] =
                                              !_isExpanded[index];
                                        });
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Question Title
                                          Expanded(
                                            child: Text(
                                              faq['title']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Arrow Icon
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
                                    // FAQ Answer (Expandable)
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
                                    // Conditionally render the Divider for all except the last item
                                    if (index != faqs.length - 1)
                                      Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
