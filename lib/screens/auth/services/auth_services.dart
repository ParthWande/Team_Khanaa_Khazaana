import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:ivrapp/model/user.dart';
import 'package:ivrapp/providers/user_provider.dart';
import 'package:ivrapp/widgets/showSnackBar.dart';
import 'package:provider/provider.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> signUpUser(
      {required String username,
      required String email,
      required String password}) async {
    String res =
        'User created successfully.Please Sign-In with same credentials';

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final ModelUser _user = ModelUser(
        cart: [],
          username: username,
          email: email,
          userid: cred.user!.uid,
          phoneNumber: '',
          address: '');
      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(_user.toMap());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'There already exists an account with the given email address';
      } else if (e.code == 'invalid-email') {
        res = 'the email address is not valid';
      } else if (e.code == 'weak-password') {
        res = 'Password should be of atleast 6 letters';
      }
    }

    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = 'Login Successful';
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException {
      res = 'Invalid Credentials!!';
    }
    return res;
  }

  Future<void> getUserDetails({required BuildContext context}) async {
    User currentUser = _auth.currentUser!;
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(currentUser.uid).get();
      Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(ModelUser.fromSnap(snap));
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }
}
