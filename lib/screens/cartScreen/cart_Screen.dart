import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/model/cart.dart';
import 'package:ivrapp/screens/home/drawer_screens/services/orders_services.dart';
import 'package:ivrapp/storage_methods/firestore_methods.dart';
import 'package:ivrapp/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../model/order.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/my-cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cart = [];
  Future<void> getOrders() async {
    cart = await FirestoreMethods().getCartItems(context: context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getOrders();
  }
  void redirectToURL() async {
    var url = Uri.parse("upi://pay?pa=9372846997@ybl&pn=Aniket&mc=&tid=&tr=Payment&tn=Payment&am=900.0&cu=INR");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Your Cart',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: FutureBuilder(
        future: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return Center(
              child: const CircularProgressIndicator(
                color: greenColor,
              ),
            );
          }
          return (cart.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You have no items in your cart yet.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'You can place orders via our app or via call.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: false,
                            itemCount: cart.length,
                            itemBuilder: (context, index) {
                              var order = cart[index];

                              return BuildOrdersList(cart: cart[index]);
                            }),
                      ),
                      CustomButton(callback: (){}, buttontitle: 'Order')
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class BuildOrdersList extends StatelessWidget {
  const BuildOrdersList({
    super.key,
    required this.cart,
  });

  final CartItem cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 1, color: Colors.grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(

            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.network(cart.imageurl,fit: BoxFit.contain,),
              ),
              Expanded(
                child: Text(
                  cart.medicineName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),

          // Text('Order id:         ' + text),
          // Text('Ordered at:    ' +
          //     date.toString()),
          // Text('Order total:    ₹' +
          //     order.totalCost.toString()),
        ],
      ),
    );
  }
}
