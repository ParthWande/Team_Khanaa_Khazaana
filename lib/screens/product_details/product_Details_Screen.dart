import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
import 'package:badges/badges.dart' as badge;

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details-screen';
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text('Medureka',style: TextStyle(color: whiteColor),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: badge.Badge(
                badgeAnimation: badge.BadgeAnimation.size(toAnimate: false),
                badgeContent: Text(
                  "2",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: whiteColor),
                ),
                badgeStyle:
                    badge.BadgeStyle(badgeColor: Colors.teal, elevation: 0),
                child: Icon(Icons.shopping_cart,color: whiteColor,size: 30,),
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
                      "Dolo 600mg",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Expanded(child: SizedBox()),
                    Text("123"),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Image.asset('assets/drugs.png')),
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
                  "widget.product.description",
                  textAlign: TextAlign.start,
                ),
              ),

              CustomTextButton(
                  buttonTitle: 'Add to Cart',
                  callback: () async {},
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
