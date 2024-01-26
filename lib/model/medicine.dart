import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine
{
  final String name;
  final String composition;
  final String uses;
  Medicine({required this.name,required this.composition,required this.uses});

  static Medicine fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Medicine(
      name: snapshot["name"],
      composition: snapshot["composition"],
      uses: snapshot["uses"]

    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "uses": uses,
    "composition":composition
  };

  static Medicine fromMap(Map<String,dynamic> snapshot) {
    return Medicine(
      name: snapshot["name"],
      uses: snapshot["uses"],
        composition:snapshot["composition"]

    );
  }

}