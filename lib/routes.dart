import 'package:flutter/material.dart';
import 'package:ivrapp/model/medicine.dart';
import 'package:ivrapp/model/prescription.dart';
import 'package:ivrapp/screens/cartScreen/cart_Screen.dart';
import 'package:ivrapp/screens/home/drawer_screens/account_screen.dart';
import 'package:ivrapp/screens/auth/auth_screen.dart';
import 'package:ivrapp/screens/chatscreen/chatscreen.dart';
import 'package:ivrapp/screens/extracted_med_list/extracted-med-list.dart';
import 'package:ivrapp/screens/home/drawer_screens/prescriptions_screen.dart';
import 'package:ivrapp/screens/home/drawer_screens/widgets/individual_prescription.dart';
import 'package:ivrapp/screens/home/drawer_screens/widgets/my_orders_screen.dart';
import 'package:ivrapp/screens/home/home_screen.dart';
import 'package:ivrapp/screens/crop_image/crop_image_screen.dart';
import 'package:ivrapp/screens/individual_Category_page/individual_category_page.dart';
import 'package:ivrapp/screens/product_details/product_Details_Screen.dart';
import 'package:ivrapp/screens/search/search_screen.dart';

Route getRoutes(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return const AuthScreen();
      });
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return const HomeScreen();
      });

    case CropImageScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        var filedetails=routeSettings.arguments as Map<String,dynamic>;
        return  CropImageScreen(filedetails: filedetails,);
      });
    case ChatScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return  ChatScreen();
      });
    case MedicineList.routeName:
      return MaterialPageRoute(builder: (context) {
        var medicines=routeSettings.arguments as List<String>;
        return  MedicineList(medicines: medicines,);
      });
    case MyAccount.routeName:
      return MaterialPageRoute(builder: (context) {
        return  MyAccount();
      });
    case PrescriptionScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return  PrescriptionScreen();
      });
    case IndividualPrescriptionPage.routeName:
      return MaterialPageRoute(builder: (context) {
        var prescription=routeSettings.arguments as Prescription;
        return  IndividualPrescriptionPage(prescription: prescription);
      });
    case MyOrdersScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return  MyOrdersScreen();
      });
    case SearchScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        var searchQuery=routeSettings.arguments as String;
        return  SearchScreen(searchQuery: searchQuery,);
      });
    case ProductDetailsScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        var medicine=routeSettings.arguments as Medicine;
        return  ProductDetailsScreen(medicine: medicine,);
      });
    case CategoryScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        var category=routeSettings.arguments as String;
        return  CategoryScreen(category: category,);
      });
    case CartScreen.routeName:
      return MaterialPageRoute(builder: (context) {
        return  CartScreen();
      });
    default:
      return MaterialPageRoute(builder: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Route don\'t exist'),
          ),
        );
      });
  }
}
