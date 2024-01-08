import 'package:flutter/material.dart';
import 'package:ivrapp/screens/auth/auth_screen.dart';
import 'package:ivrapp/screens/chatscreen/chatscreen.dart';
import 'package:ivrapp/screens/extracted_med_list/extracted-med-list.dart';
import 'package:ivrapp/screens/home/home_screen.dart';
import 'package:ivrapp/screens/crop_image/crop_image_screen.dart';

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
