import 'package:flutter/cupertino.dart';
import 'package:ivrapp/model/user.dart';

class UserProvider extends ChangeNotifier
{
  ModelUser _user=ModelUser(username: '', email: '', userid: '', phoneNumber: '', address: '',cart: []);
  ModelUser get user=>_user;

  void getUserDetails(ModelUser user)
   {
    _user=user;
    notifyListeners();
  }

}