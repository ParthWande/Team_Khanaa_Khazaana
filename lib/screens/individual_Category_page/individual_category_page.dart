import 'package:flutter/material.dart';

import '../../httprequests/get_Category_recommendations.dart';
import '../../model/medicine.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category-screen';
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Medicine>? medicines;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMedicines();
  }

  void getMedicines() async {
    medicines = await ProductServices()
        .getMedbyCategory(context: context, category: widget.category);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
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
              onPressed: () {},
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return CategoryInfoTile(
            medicine: medicines![index],
          );
        },
        itemCount: medicines!.length,
      ),
    );
  }
}

class CategoryInfoTile extends StatelessWidget {
  CategoryInfoTile({required this.medicine});
  Medicine medicine;

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
                          medicine.name,
                          style: TextStyle(fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          medicine.composition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
