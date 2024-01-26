import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/screens/cartScreen/cart_Screen.dart';
import 'package:ivrapp/screens/chatscreen/chatscreen.dart';
import 'package:ivrapp/screens/product_details/product_Details_Screen.dart';
import 'package:badges/badges.dart' as badge;
import '../../httprequests/get_Category_recommendations.dart';
import '../../model/medicine.dart';
import '../../storage_methods/firestore_methods.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category-screen';
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Medicine>? medicines;
  int cartItemCount=0;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMedicines();
    getCartLength();
  }

  void getMedicines() async {
    setState(() {
      isLoading = true;
    });
    medicines = await ProductServices()
        .getMedbyCategory(context: context, category: widget.category);
    setState(() {
      isLoading = false;
    });
  }
  Future<void> getCartLength() async {
    cartItemCount = await FirestoreMethods().getCartItemCount();
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
            onPressed: ()
            {

            },
          ),
          FutureBuilder(
            builder:(context,snapshot)
          {
            if(snapshot.connectionState==ConnectionState.waiting)
            {

            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                onPressed: ()
                {
                  Navigator.pushNamed(context, CartScreen.routeName);
                },
                icon: badge.Badge(
                  badgeAnimation: badge.BadgeAnimation.size(toAnimate: false),
                  badgeContent: Text(
                    cartItemCount == 0 ? 0.toString() : cartItemCount.toString(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: whiteColor),
                  ),
                  badgeStyle:
                  badge.BadgeStyle(badgeColor: Colors.teal, elevation: 0),
                  child: Icon(
                    Icons.shopping_cart,
                    color: whiteColor,
                    size: 30,
                  ),
                ),
              ),
            );
          }, future: getCartLength(),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: (isLoading)
          ? Center(
              child: const CircularProgressIndicator(
              color: greenColor,
            ),)
          : ListView.builder(
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
      onPressed: ()
      {
        Navigator.pushNamed(context, ProductDetailsScreen.routeName,arguments: medicine);
      },
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
                  child: Image.network(
                    medicine.image_urls,
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
