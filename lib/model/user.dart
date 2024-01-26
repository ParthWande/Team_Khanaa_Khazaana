import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ivrapp/model/cart.dart';

class ModelUser {
  final String username;
  final String email;
  final String phoneNumber;
  final String userid;
  final String address;
  final List<CartItem> cart;
  ModelUser(
      {required this.username,
      required this.email,
      required this.userid,
      required this.phoneNumber,
       required this.cart,
      required this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': userid,
      'username': username,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
      "cart":cart
    };
  }

  static ModelUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return ModelUser(
        email: snapshot['email'],
        cart: snapshot['cart']??[],
        username: snapshot['username'],
        userid: snapshot['id'],
        phoneNumber: snapshot['phoneNumber'],
        address: snapshot['address']);
  }
}
