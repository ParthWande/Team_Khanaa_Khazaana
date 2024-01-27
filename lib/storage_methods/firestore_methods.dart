import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:ivrapp/httprequests/get_ocr_result.dart';
import 'package:ivrapp/model/cart.dart';
import 'package:ivrapp/model/prescription.dart';
import 'package:ivrapp/providers/prescription_provider.dart';
import 'package:ivrapp/storage_methods/store_prescriptions.dart';
import 'package:ivrapp/widgets/showSnackBar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> uploadPrescriptionDetails(
      {required BuildContext context,
      required Map<String, dynamic> filedetails}) async {
    List<String> medicines = [];
    try {
      String url = await FirebaseStorageMethods()
          .uploadtoFirestorage(context: context, filedetails: filedetails);
      Random random = Random();
      // Generate a 4-digit random number
      int fourDigitNumber = random.nextInt(9000) + 1000;
      String id = fourDigitNumber.toString();
      Prescription _prescription = Prescription(
          userid: _auth.currentUser!.uid,
          prescriptionUrl: url,
          uploadDate: DateTime.now().toString(),
          medicines: [],
          id: id,
          fileName: filedetails['name']);
      await _firestore
          .collection('prescriptions')
          .doc(id)
          .set(_prescription.toJson());

      medicines = await getOcrResult(prescriptionUrl: url, context: context);
      print(medicines);
      await FirestoreMethods().getPrescriptionDetails(context: context, id: id);

      // await uploadExtractedMedicines(context: context, id: id, medicines: medicines);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return medicines;
  }

  Future<void> uploadExtractedMedicines(
      {required BuildContext context,
      required String id,
      required List<String> medicines}) async {
    try {
      await _firestore
          .collection('prescriptions')
          .doc(id)
          .update({"medicines": FieldValue.arrayUnion(medicines)});

      await FirestoreMethods().getPrescriptionDetails(context: context, id: id);
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  Future<void> getPrescriptionDetails(
      {required BuildContext context, required String id}) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('prescriptions').doc(id).get();
      Provider.of<PrescriptionProvider>(context, listen: false)
          .getPrescription(Prescription.fromSnap(snap));
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  Future<void> uploadToCart(
      {required BuildContext context,
      required String medicineName,
      required String imageUrl,
      required int quantity}) async {
    List<CartItem> cart = [];
    String id = Uuid().v4();
    CartItem cartItem = CartItem(
        price: 100,
        medicineName: medicineName,
        quantity: quantity,
        userid: _auth.currentUser!.uid,
        id: id,
        imageurl: imageUrl);
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .add(cartItem.toJson());
      print('Item added to cart successfully');
    } catch (e) {
      print('Error adding item to cart: $e');
      // Handle the error appropriately
    }
  }

  Future<List<CartItem>> getCartItems({required BuildContext context}) async {
    List<CartItem> cartItems = [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        CartItem cartItem = CartItem.fromSnap(document);
        cartItems.add(cartItem);
      }

      return cartItems;
    } catch (e) {
      showSnackBar(context,
          e.toString()); // Return an empty list or handle the error as needed
    }
    return cartItems;
  }

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<int> getCartItemCount() async {
    try {
      QuerySnapshot querySnapshot = await usersCollection
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error retrieving cart item count: $e');
      return 0; // Return 0 or handle the error as needed
    }
  }

  Future<num> calculateTotalSum({required BuildContext context}) async {
    num totalSum = 0;
    try {
      // Query the 'carts' collection based on user ID
      QuerySnapshot<Map<String, dynamic>> cartItems = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .get();
      // Loop through the documents and add the 'price' to the total sum
      cartItems.docs.forEach((DocumentSnapshot<Map<String, dynamic>> cartItem) {
        totalSum += cartItem['price'] ?? 0;
      });
    } catch (err) {
      showSnackBar(context, err.toString());
    }
    return totalSum;
  }
}
