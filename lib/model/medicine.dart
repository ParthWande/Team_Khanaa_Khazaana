import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine
{
  final String name;
  final String composition;
  final String uses;
  final String image_urls;
  Medicine({required this.name,required this.composition,required this.uses,required this.image_urls});

  static Medicine fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Medicine(
      name: snapshot["name"],
        image_urls: snapshot["image_urls"],
      composition: snapshot["composition"],
      uses: snapshot["uses"]

    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "uses": uses,
    "composition":composition,
    "image_urls":image_urls
  };

  static Medicine fromMap(Map<String,dynamic> snapshot) {
    return Medicine(
        image_urls: snapshot["image_urls"],
      name: snapshot["name"],
      uses: snapshot["uses"],
        composition:snapshot["composition"]

    );
  }
  static List<Medicine> fromList(List<dynamic> list) {
    return list.map((item) => fromMap(item)).toList();
  }
}

