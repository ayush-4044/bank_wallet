import 'package:flutter/material.dart';

void main() {
  runApp(EWalletApp());
}

class EWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 100,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("Welcome Back!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  )),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Ayush Hirpara",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              )
                            ],
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: Colors.deepPurple,
                                size: 28,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverAppBar(
              expandedHeight: 200,
              backgroundColor: Colors.deepPurple,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                centerTitle: false,
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\₹5,27,00.00",
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    )
                  ],
                ),
                title: Text(
                  "Wallet",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 170,
              toolbarHeight: 170,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Quick actions",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(icon: Icons.send, label: "Send"),
                          _buildQuickAction(icon: Icons.receipt, label: "Request"),
                          _buildQuickAction(icon: Icons.add, label: "Top Up"),
                        ],
                      ),
                    ],
                  )),
            ),
            SliverToBoxAdapter(
              // ignore: prefer_const_constructors
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Recent Transaction",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildTransactionTitle(
                      title: "Transaction $index",
                      subtitle: "Details of transaction $index",
                      amount: (index.isEven ? "+" : "-") + "\₹${(index + 1) * 20}",
                      isPositive: index.isEven);
                }, childCount: 20)),
            SliverFillRemaining(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Explore New Features",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Stay tunned for exciting updates and improvements",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Learn more",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 30,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14),
        )
      ],
    );
  }

  Widget _buildTransactionTitle(
      {required String title,
        required String subtitle,
        required String amount,
        required isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: Text(
            amount,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red),
          ),
        ),
      ),
    );
  }
}
