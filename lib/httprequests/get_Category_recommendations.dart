import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ivrapp/model/medicine.dart';
import 'package:ivrapp/widgets/http_error_handling.dart';
import 'package:ivrapp/widgets/showSnackBar.dart';

class ProductServices {
  Future<List<Medicine>> getMedbyCategory(
      {required BuildContext context, required String category}) async {
    List<Medicine>? medicineList;
    try {
      http.Response res = await http.get(
        Uri.parse('https://5016-2409-40c0-78-1aee-b875-4543-9afa-26bb.ngrok-free.app/medicine/$category'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorhandle(
          context: context,
          res: res,
          onSuccess: () {
            Map<String, dynamic> parsedJson = json.decode(res.body);

            // Access the list of medicine data
            List<dynamic> medicineDataList = parsedJson['medicine_data'];

            // Convert each object in "medicine_data" to a Medicine object
            medicineList = Medicine.fromList(medicineDataList);
            for (Medicine medicine in medicineList!) {
              print('Medicine Name: ${medicine.name}');
              print('Composition: ${medicine.composition}');
              print('Uses: ${medicine.uses}');
              print('------------------------');
            }
          });

  //     String jsonResponse = '''
  // {
  //   "medicine_data": [
  //     {
  //       "composition": "Clindamycin (1% w/w) + Nicotinamide (4% w/w)",
  //       "name": "Clearbet Gel",
  //       "uses": "Treatment of Acne"
  //     },
  //     {
  //       "composition": "Adapalene (0.1% w/w)",
  //       "name": "Adaferin Gel",
  //       "uses": "Acne"
  //     }
  //   ]
  // }
  // ''';
  //     Map<String, dynamic> parsedJson = json.decode(jsonResponse);
  //
  //     // Access the list of medicine data
  //     List<dynamic> medicineDataList = parsedJson['medicine_data'];
  //
  //     // Convert each object in "medicine_data" to a Medicine object
  //     medicineList = Medicine.fromList(medicineDataList);
  //     for (Medicine medicine in medicineList!) {
  //       print('Medicine Name: ${medicine.name}');
  //       print('Composition: ${medicine.composition}');
  //       print('Uses: ${medicine.uses}');
  //       print('------------------------');
  //     }

    } catch (err) {
      showSnackBar(context, err.toString());
    }
    return medicineList!;
  }
}
