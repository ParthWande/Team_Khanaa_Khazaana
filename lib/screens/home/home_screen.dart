import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/model/user.dart';
import 'package:ivrapp/providers/user_provider.dart';
import 'package:ivrapp/screens/auth/services/auth_services.dart';
import 'package:ivrapp/screens/chatscreen/chatscreen.dart';
import 'package:ivrapp/screens/home/drawer_screens/services/orders_services.dart';
import 'package:ivrapp/screens/search/search_screen.dart';
import 'package:ivrapp/widgets/custom_textfield.dart';
import 'package:ivrapp/widgets/show_drawer.dart';
import 'package:provider/provider.dart';

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
    ModelUser user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      drawer: showDrawer(context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          makeCall();
        },
        child: Icon(
          Icons.phone,
          color: Colors.black,
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: HomeBody(),
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
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                ))
              ],
            ),
            OrderOptions()
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String cardTitle;
  final String imageUrl;
  final VoidCallback callback;
  const OrderCard(
      {super.key,
      required this.cardTitle,
      required this.callback,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 4,
      color: whiteColor,
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
              Navigator.pushNamed(context, SearchScreen.routeName,
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
              OrderTypeCard(title: "Whatsapp",icon: Icons.whatshot,),
            OrderTypeCard(title: "Call",icon: Icons.add_call,),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Expanded(
              child: Material(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: whiteColor),
                  child: Row(

                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.green,
                        ),
                      ),
                      Text('Upload Prescription'),
                      Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const OrderTypeCard({
    super.key,
    required this.title,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          elevation: 4,
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
                  child: Icon(icon,
                      color: Colors.green),
                ),
                Text(title),
                Icon(Icons.chevron_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyGradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4, // Adjust the height of the divider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey,
            Colors.white10
          ], // Adjust the gradient colors
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
    );
  }
}

class MyFadingGradientDividerWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 4, // Adjust the height of the divider
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.red, // Adjust the starting color
                      Colors.transparent,
                      Colors.transparent,
                      Colors.blue, // Adjust the ending color
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.1, 0.5, 0.9, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
            ),
            Text(
              'Your Centered Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
