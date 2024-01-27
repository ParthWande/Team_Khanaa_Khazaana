import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
import 'package:badges/badges.dart' as badge;
import 'package:ivrapp/model/medicine.dart';
import 'package:ivrapp/screens/cartScreen/cart_Screen.dart';
import 'package:ivrapp/storage_methods/firestore_methods.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';
import '../../providers/user_provider.dart';
import '../auth/services/auth_services.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details-screen';
  final Medicine medicine;
  const ProductDetailsScreen({super.key, required this.medicine});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int cartItemCount = 0;
  void initState() {
    // TODO: implement initState
    super.initState();
    //getData();
    getCartLength();
  }

  void getCartLength() async {
     cartItemCount = await FirestoreMethods().getCartItemCount();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          'Medureka',
          style: TextStyle(color: whiteColor),
        ),
        actions: [
          Padding(
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
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.medicine.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Image.network(widget.medicine.image_urls)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Price: ₹ ' + '100',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  widget.medicine.uses,
                  textAlign: TextAlign.start,
                ),
              ),
              CustomTextButton(
                  buttonTitle: 'Add to Cart',
                  callback: () async {
                    await FirestoreMethods().uploadToCart(
                        context: context,
                        medicineName: widget.medicine.name,
                        imageUrl: widget.medicine.image_urls,
                        quantity: 1);

                    setState(() {
                      cartItemCount++;
                    });
                  },
                  color: greenColor),
            ],
          ),
        ),
      ),
    );
    ;
  }
}

class CustomTextButton extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback callback;
  final Color color;
  const CustomTextButton(
      {super.key,
      required this.buttonTitle,
      required this.callback,
      this.color = greenColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          minimumSize:
              MaterialStateProperty.all(const Size(double.infinity, 40)),
          backgroundColor: MaterialStateProperty.all(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        onPressed: callback,
        child: Text(
          buttonTitle,
          style: TextStyle(color: whiteColor),
        ));
  }
}
