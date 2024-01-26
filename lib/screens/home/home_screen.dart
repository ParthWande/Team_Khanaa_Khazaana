import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/get_user_location.dart';
import 'package:ivrapp/httprequests/get_Category_recommendations.dart';
import 'package:ivrapp/model/user.dart';
import 'package:ivrapp/providers/user_provider.dart';
import 'package:ivrapp/screens/auth/services/auth_services.dart';
import 'package:ivrapp/screens/chatscreen/chatscreen.dart';
import 'package:ivrapp/screens/home/drawer_screens/services/orders_services.dart';
import 'package:ivrapp/screens/product_details/product_Details_Screen.dart';
import 'package:ivrapp/screens/search/search_screen.dart';
import 'package:ivrapp/widgets/custom_textfield.dart';
import 'package:ivrapp/widgets/show_drawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pick_file.dart';
import '../../widgets/showAlert.dart';
import '../crop_image/crop_image_screen.dart';
import '../individual_Category_page/individual_category_page.dart';

late String lat;
late String long;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getData();
    AuthServices().getUserDetails(context: context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void addOrder() async {
    await OrderServices().uploadOrder(context: context);
  }

  @override
  Widget build(BuildContext context) {
    ModelUser user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.green[50],
      drawer: showDrawer(context: context),
      appBar: AppBar(
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(child: HomeBody()),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final TextEditingController _searchcontroller = TextEditingController();
  Position? userlocation;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchcontroller.dispose();
  }

  void redirectToURL({required String query}) async {
    Position position = await determinePosition();
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });

    var url = Uri.parse(
        "https://www.google.com/maps/search/$query/@$lat,$long,15.25z?entry=ttu");
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Material(
              color: whiteColor,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SearchMed(
                        hintText: 'Search a medicine',
                        controller: _searchcontroller,
                        keyboardType: TextInputType.text),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: OrderCard(
                          cardTitle: 'Order Medicines',
                          imageUrl: 'assets/drugs.png',
                          callback: () {},
                          color: Color(0xFFAFFFC5),
                        )),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: OrderCard(
                          cardTitle: 'Ask Chatbot',
                          imageUrl: 'assets/chatbot.png',
                          callback: () {
                            Navigator.pushNamed(context, ChatScreen.routeName);
                          },
                          color: Color(0xFF8DF4F8),
                        ))
                      ],
                    ),
                    OrderOptions(),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: whiteColor,
            elevation: 4,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Services Near You',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: serviceNames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ServiceCard(
                            callback: () {
                              redirectToURL(query: serviceNames[index]);
                            },
                            serviceTitle: serviceNames[index],
                            serviceImage: serviceImage[index],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            color: whiteColor,
            elevation: 4,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Shop by Categories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CategoryNames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ServiceCard(
                            callback: () {
                              Navigator.pushNamed(
                                  context, CategoryScreen.routeName,
                                  arguments: CategoryNames[index]);
                            },
                            serviceTitle: CategoryNames[index],
                            serviceImage: CategoryImage[index],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final VoidCallback callback;
  final String serviceTitle;
  final String serviceImage;
  const ServiceCard({
    super.key,
    required this.serviceTitle,
    required this.serviceImage,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(8),
          width: 180,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(serviceImage), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(10),
            color: whiteColor,
          ),
          child: Text(
            serviceTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String cardTitle;
  final String imageUrl;
  final Color color;
  final VoidCallback callback;
  const OrderCard(
      {super.key,
      required this.cardTitle,
      required this.color,
      required this.callback,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 4,
      color: color,
      child: GestureDetector(
        onTap: callback,
        child: Container(
          width: 190,
          height: 100,
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 72,
                child: Text(
                  cardTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  child: Image.asset(
                    imageUrl,
                    height: 40,
                    width: 40,
                  ),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class SearchMed extends StatelessWidget {
  final hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  SearchMed(
      {required this.hintText,
      required this.controller,
      required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: keyboardType,
        controller: controller,
        textInputAction: TextInputAction.next,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Enter your ${hintText}';
          }
          return null;
        },
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              (controller.text.isEmpty)
                  ? null
                  : Navigator.pushNamed(context, SearchScreen.routeName,
                      arguments: controller.text.trim());
            },
            icon: Icon(Icons.search),
          ),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: redColor)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: redColor),
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: greenColor),
          ),
        ),
      ),
    );
  }
}

class OrderOptions extends StatefulWidget {
  const OrderOptions({super.key});

  @override
  State<OrderOptions> createState() => _OrderOptionsState();
}

class _OrderOptionsState extends State<OrderOptions> {
  Map<String, dynamic>? filedetails;
  void getCroppedImage() async {
    filedetails = await Pickfile().cropImage(context: context);

    Navigator.pushNamed(context, CropImageScreen.routeName,
        arguments: filedetails!);
  }

  void makeCall() async {
    // final Uri url = Uri(scheme: "tel", path: phoneNum);
    // try {
    //   if (await canLaunchUrl(url)) {
    //     await launchUrl(url);
    //   }
    // } catch (e) {
    //   print(e);
    // }
    FlutterPhoneDirectCaller.callNumber(phoneNum);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Or Order Via',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              OrderTypeCard(
                title: "Prescription",
                icon: Icons.camera_alt,
                callback: () {
                  showAlert(
                      context: context, title: '', callback: getCroppedImage);
                },
              ),
              OrderTypeCard(
                title: "Call",
                icon: Icons.add_call,
                callback: () {
                  makeCall();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback callback;
  const OrderTypeCard(
      {super.key,
      required this.title,
      required this.callback,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          elevation: 4,
          child: GestureDetector(
            onTap: callback,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: whiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(icon, color: Colors.green),
                  ),
                  Text(title),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
