import 'package:app/constant/appcolor.dart';
import 'package:app/controller/consultationrequest.dart';
import 'package:app/controller/usercontroller.dart';
import 'package:app/widget/custombackbutton.dart';
import 'package:app/widget/requestwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class RequestList extends StatelessWidget {
  const RequestList({super.key});

  @override
  Widget build(BuildContext context) {
    final requestController =
        Provider.of<ConsultationRequestController>(context);
    return Scaffold(
      floatingActionButton: Container(
        padding: const EdgeInsets.all(12),
        child: FloatingActionButton.extended(
            label: Text(
              'Tambah',
              style: TextStyle(
                  color: AppColor.secondary, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColor.tertiary,
            icon: const Icon(
              Icons.add,
              color: AppColor.secondary,
            ),
            onPressed: () => Navigator.of(context).pushNamed('/request')),
      ),
      body: FutureBuilder(
          future: requestController.fetchData(
              Provider.of<UserController>(context, listen: false).farmId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.orange, size: 60),
              );
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(children: [
                SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        color: AppColor.secondary,
                        height: 130,
                        child: Padding(
                          padding: EdgeInsets.only(left: 105, top: 25),
                          child: Text(
                            'Usulan Konsultasi',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                      const CustomBackButton(color: AppColor.quaternary),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    itemBuilder: (context, index) =>
                        RequestWidget(data: requestController.list[index]),
                    // Text(requestController.list[index].deskripsi),
                    itemCount: requestController.list.length,
                  ),
                ),
              ]),
            );
          }),
    );
  }
}