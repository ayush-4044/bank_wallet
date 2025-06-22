import 'dart:convert';
import 'package:bookyourev/admin/admin_add_category.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;
import '../CommonWidget/apiconst.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Example category data
  String? data;
  List category = [];
  var logindata;
  bool isLoading = false;
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${Apiconst.base_url}admin_view_category.php");
    var response = await http.get(
      url,
      headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
    );

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      setState(() {
        category = decodedData["category"]?.toList() ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Failed to load data",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    }
  }


  // Function to delete a category with confirmation dialog
  void _deleteCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5F5F5),
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.black),
              ),
            ),
            // Delete Button
            TextButton(
              onPressed: () {
                _deleteCategoryAPI(categoryId);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategoryAPI(String categoryId) async {
    setState(() {
      isLoading = true;
    });
    final login_url =
        Uri.parse("${Apiconst.base_url}admin_delete_category.php");
    final response = await http.post(login_url,
        headers: {'cookie': Apiconst.cookie, 'User-Agent': Apiconst.user_agent},
        body: {"cat_id": categoryId});

    print(response.body);
    if (response.statusCode == 200) {
      logindata = jsonDecode(response.body);
      print(logindata);
      setState(() {
        getData();
      });
      if (logindata['error'] == false) {
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            color: Colors.white,
            onPressed: () {
              // Navigate to AddCategoryPage
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCategoryPage(),
                  )).whenComplete(() {
                setState(() {
                  getData();
                });
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : category.isEmpty
              ? Center(
                  child: Text(
                    'No Category Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      // final category = category[index];
                      return Column(
                        children: [
                          CategoryCard(
                            categoryName: category[index]['cat_name']!,
                            categoryDescription: category[index]
                                ['cat_description']!,
                            onTap: () {},
                            onDelete: () =>
                                _deleteCategory(category[index]['cat_id']),
                          ),

                          const SizedBox(
                              height: 16), // Reduced spacing for better UI
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String categoryDescription;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryDescription,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFFF5F5F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed:
                        onDelete, // Use the callback instead of directly calling _deleteCategory
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                categoryDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
