import 'package:app/constant/appcolor.dart';
import 'package:app/controller/consultationcontroller.dart';
import 'package:app/model/consultationmodel.dart';
import 'package:app/widget/customdialog.dart';
import 'package:app/widget/customtop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateResult extends StatefulWidget {
  const CreateResult({super.key});

  @override
  State<CreateResult> createState() => _CreateResultState();
}

class _CreateResultState extends State<CreateResult> {
  final diagnosaController = TextEditingController();
  final penjelasanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final consultationData =
        ModalRoute.of(context)!.settings.arguments as ConsultationModel;
    print(consultationData.konsultasiId);
    print(consultationData.usulanKonsultasiId);
    void tryCreate() async {
      final diagnosa = diagnosaController.text;
      final penjelasan = penjelasanController.text;
      if (diagnosa.isEmpty || penjelasan.isEmpty) {
        customDialog(
            context, 'Gagal', 'Data hasil konsultasi tidak boleh kosong!');
        return;
      }

      Provider.of<ConsultationController>(context, listen: false)
          .createResult(diagnosa, penjelasan, consultationData)
          .then((value) => Navigator.pushReplacementNamed(context, '/home'));
    }

    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          outlineBorder: BorderSide(color: Colors.grey),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          filled: true,
          fillColor: AppColor.formcolor,
        ),
      ),
      child: Scaffold(
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Berikan Hasil Konsultasi'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Diagnosa'),
                    TextField(
                      controller: diagnosaController,
                    ),
                    Text('Penjelasan'),
                    TextField(
                      controller: penjelasanController,
                      maxLines: 10,
                      decoration:
                          InputDecoration(contentPadding: EdgeInsets.all(20)),
                    ),
                    InkWell(
                      onTap: tryCreate,
                      child: Text('ss'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomTop(title: 'Berikan Hasil')
        ]),
      ),
    );
  }
}