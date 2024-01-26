import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String medicineName;
  final int quantity;
  final String userid;
  final String id;
  final String imageurl;

  CartItem(
      {required this.medicineName,
      required this.quantity,
      required this.userid,
        required this.imageurl,
      required this.id});

  static CartItem fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return CartItem(
      userid: snapshot["userid"]??'',
      medicineName: snapshot["medicineName"],
      quantity: (snapshot["quantity"]),
      id: snapshot["id"]??'', imageurl: snapshot["imageurl"],
    );
  }

  Map<String, dynamic> toJson() => {
    "userid": userid,
    "medicineName": medicineName,
    "id": id,
    "quantity":quantity,
    "imageurl":imageurl
  };

}
