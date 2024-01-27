import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/model/prescription.dart';

class IndividualPrescriptionPage extends StatelessWidget {
  static const routeName = '/indi-presc-screen';
  final Prescription prescription;
  const IndividualPrescriptionPage({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Prescription Details',
          style: TextStyle(color: whiteColor),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'unique id: '+prescription.id.substring(prescription.id.length - 4),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  )),
            ),
            DottedBorder(
              dashPattern: [6, 3, 6, 3],
              borderPadding: EdgeInsets.all(10),
              borderType: BorderType.RRect,
              radius: Radius.circular(15),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(
                    prescription.prescriptionUrl,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                'Medicines ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: prescription.medicines.map((e) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("   • ", style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ))
          ],
        ),
      ),
    );
  }
}
