import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  static const routeName = '/search-screen';
  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 30,
              ),
              onPressed: (){},
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ProductInfoTile();
        },
        itemCount: 6,
      ),
    );
  }
}

class ProductInfoTile extends StatelessWidget {
  ProductInfoTile();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: () {},
        child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(4),
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 140,
                      child: Image.asset(
                        'assets/drugs.png',
                        fit: BoxFit.contain,
                        width: 200,
                        height: 125,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'V.I.R.U.S-Inverter',
                              style: TextStyle(fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Best Product',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('₹ ' + "1000",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              10 == 0 ? 'Out of stock' : 'In stock',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: 10 == 0 ? Colors.red : Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
            ),
        );
    }
}