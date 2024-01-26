import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
import 'package:ivrapp/model/prescription.dart';
import 'package:ivrapp/providers/prescription_provider.dart';
import 'package:ivrapp/screens/home/home_screen.dart';
import 'package:ivrapp/storage_methods/firestore_methods.dart';
import 'package:ivrapp/widgets/custom_button.dart';
import 'package:ivrapp/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class MedicineList extends StatefulWidget {
  static const routeName = '/med-list';
  final List<String> medicines;
  MedicineList({super.key, required this.medicines});

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  final TextEditingController _medcontroller = TextEditingController();
  bool isLoading = false;
  void getInitialMedList() {
    _medcontroller.text = widget.medicines.join(',');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialMedList();
  }

  void uploadFinalMedicines({required String id}) async {
    List<String> wordList = _medcontroller.text.trim().split(',');
    setState(() {
      isLoading = true;
    });
    await FirestoreMethods().uploadExtractedMedicines(
        context: context, id: id, medicines: wordList);
    setState(() {
      isLoading = false;
    });
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Prescription prescription =
        Provider.of<PrescriptionProvider>(context).prescription;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(8),
                height: 400,
                child: FutureBuilder(
                  future: precacheImage(
                      NetworkImage(prescription.prescriptionUrl), context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: greenColor,
                      ));
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.error == null) {
                      return DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Container(
                            margin: EdgeInsets.all(8),
                            height: 400,
                            color: Colors.transparent,
                            child: Image.network(
                              prescription.prescriptionUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Text('Error loading image');
                    }
                  },
                ),
              ),
              CustomTextFormField(
                maxLines: null,
                  hintText: '',
                  controller: _medcontroller,
                  keyboardType: TextInputType.text),
              (isLoading)
                  ? Container(
                      height: 48,
                      margin: EdgeInsets.all(8),
                      color: greenColor,
                      width: double.infinity,
                      child: Center(
                        child: const CircularProgressIndicator(
                          color: whiteColor,
                        ),
                      ),
                    )
                  : CustomButton(
                      callback: () => uploadFinalMedicines(id: prescription.id),
                      buttontitle: 'Submit'),
            ],
          ),
        ),
      ),
    );
  }
}
