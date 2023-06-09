import 'package:app/constant/app_color.dart';
import 'package:app/constant/request_status.dart';
import 'package:app/constant/role.dart';
import 'package:app/controller/c_doctor.dart';
import 'package:app/controller/c_auth.dart';
import 'package:app/model/m_konsultasi.dart';
import 'package:app/model/m_usulan_konsultasi.dart';
import 'package:app/model/m_peternakan.dart';
import 'package:app/model/m_akun.dart';
import 'package:app/widget/consultation_data.dart';
import 'package:app/widget/consultation_status.dart';
import 'package:app/widget/custom_top.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsultationView extends StatelessWidget {
  const ConsultationView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    final cAuth = Provider.of<CAuth>(context, listen: false);
    final peternakanData = data[0] as MPeternakan;
    final isPemilik = cAuth.getDataProfile().role == UserRole.pemilik;
    final dokterData = data[1] as MAkun;
    final consultationRequestData = data[2] as MUsulanKonsultasi;
    final consultationData = data[3] as MKonsultasi;

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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColor.tertiary,
          label: const Text(
            'Pesan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.secondary,
            ),
          ),
          icon: const Icon(
            Icons.message_rounded,
            color: AppColor.secondary,
          ),
          onPressed: () async {
            MAkun continuedData = dokterData;
            if (cAuth.getDataProfile().role == UserRole.dokter) {
              final data = await FirebaseFirestore.instance
                  .collection('akun')
                  .where('peternakanId', isEqualTo: peternakanData.peternakanId)
                  .where('role', isEqualTo: UserRole.pemilik)
                  .limit(1)
                  .get();
              continuedData =
                  MAkun.fromJson(data.docs[0].data(), data.docs[0].id);
            }
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/chat-view',
                arguments: continuedData);
          },
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 160,
                  ),
                  ConsultationStatus(
                    status: consultationData.status,
                    hasilId: consultationData.hasilId,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      if (isPemilik) {
                        final result =
                            await Provider.of<CDoctor>(context, listen: false)
                                .getDataProfileDokter(dokterData);
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamed(context, '/doctor-view',
                            arguments: [result, false]);
                      } else {
                        Navigator.pushNamed(context, '/farm-data',
                            arguments: peternakanData);
                      }
                    },
                    child: ConsultationData(
                        imageUrl: isPemilik
                            ? dokterData.downloadUrl
                            : peternakanData.downloadUrl,
                        nama: isPemilik ? dokterData.nama : peternakanData.nama,
                        title: isPemilik ? "Dokter" : "Konsultan"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (cAuth.getDataProfile().role == UserRole.dokter)
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/view-farm-data',
                        arguments: consultationRequestData.musimId,
                      ),
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green,
                          ),
                          child: const Text(
                            'Lihat Data Harian Peternakan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  ConsultationDataWidget(
                      title: 'Tanggal',
                      data: consultationRequestData.tanggal,
                      moreThanOneLine: false),
                  ConsultationDataWidget(
                      title: 'Judul Konsultasi',
                      data: consultationRequestData.judul,
                      moreThanOneLine: false),
                  ConsultationDataWidget(
                      title: 'Deskripsi',
                      data: consultationRequestData.deskripsi,
                      moreThanOneLine: true),
                  const Text(
                    'Foto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      if (consultationRequestData.downloadUrl.isNotEmpty) {
                        Navigator.pushNamed(context, '/photo-view',
                            arguments: consultationRequestData.downloadUrl);
                      }
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: consultationRequestData.downloadUrl.isEmpty
                                  ? const AssetImage(
                                      "assets/images/no-photo-available.png")
                                  : NetworkImage(
                                      consultationRequestData.downloadUrl,
                                    ) as ImageProvider),
                          color: AppColor.formcolor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1.5, color: AppColor.formborder)),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (!isPemilik &&
                      consultationData.status == RequestStatus.berlangsung)
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, '/create-result',
                          arguments: consultationData),
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: AppColor.tertiary,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          'BERIKAN HASIL KONSULTASI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
          const CustomTop(title: 'Detail Konsultasi'),
        ]),
      ),
    );
  }
}

class ConsultationData extends StatelessWidget {
  const ConsultationData(
      {super.key,
      required this.nama,
      // required this.peternakanData,
      required this.imageUrl,
      required this.title});
  final String nama;
  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                nama,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(
                width: 12,
              ),
              CircleAvatar(
                  radius: 24,
                  backgroundImage: imageUrl.isEmpty
                      ? const AssetImage('assets/images/profile.png')
                      : NetworkImage(imageUrl) as ImageProvider),
            ],
          ),
        ),
      ],
    );
  }
}
