import 'dart:io';
import 'package:app/constant/appcolor.dart';
import 'package:app/constant/role.dart';
import 'package:app/controller/c_auth.dart';
import 'package:app/model/usermodel.dart';
import 'package:app/widget/custombackbutton.dart';
import 'package:app/widget/customdialog.dart';
import 'package:app/widget/imagepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  late String name;
  late String role;
  late String number;
  late String address;
  late String email;
  late String since;
  late String imageUrl;
  String deskripsi = '';
  int harga = 0;
  File? photo;
  bool isEditable = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final cAuth = Provider.of<CAuth>(context, listen: false).getDataProfile();
    name = cAuth.nama;
    role = cAuth.role;
    number = cAuth.noTelepon;
    address = cAuth.alamat;
    email = cAuth.email;
    since = cAuth.tanggalPendaftaran;
    imageUrl = cAuth.downloadUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cAuth = Provider.of<CAuth>(context);
    final userData = cAuth.getDataProfile();

    final UserModel? isFromConsultation =
        ModalRoute.of(context)!.settings.arguments as UserModel?;
    if (isFromConsultation != null) {
      name = isFromConsultation.nama;
      role = isFromConsultation.role;
      number = isFromConsultation.noTelepon;
      address = isFromConsultation.alamat;
      email = isFromConsultation.email;
      since = isFromConsultation.tanggalPendaftaran;
      imageUrl = isFromConsultation.downloadUrl;
    }
    void trySave() async {
      if (formKey.currentState!.validate()) {
        bool isConfirm = false;
        await NDialog(
          title: const Text(
            'Konfirmasi',
            textAlign: TextAlign.center,
          ),
          content: const Text("Apakah yakin ingin menyimpan data?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                isConfirm = true;
                Navigator.of(context).pop();
              },
              child: const Text('Iya'),
            )
          ],
        ).show(context);
        if (isConfirm) {
          formKey.currentState!.save();
          if (photo != null) {
            final upload = await FirebaseStorage.instance
                .ref(
                    '/profile-images/${FirebaseAuth.instance.currentUser!.uid}')
                .putFile(
                  File(photo!.path),
                );
            final url = await upload.ref.getDownloadURL();
            imageUrl = url;
          }

          final trimmedname = name.trim();
          final trimmedaddress = address.trim();
          final trimmedimageUrl = imageUrl.trim();
          final trimmednumber = number.trim();
          if (trimmedname != userData.nama ||
              trimmedaddress != userData.alamat ||
              trimmednumber != userData.noTelepon ||
              trimmedimageUrl != userData.downloadUrl) {
            cAuth.updateData(
              trimmedname,
              trimmednumber,
              trimmedaddress,
              trimmedimageUrl,
            );

            // ignore: use_build_context_synchronously
            customDialog(
                context, "Berhasil!", "Perubahan data berhasil dilakukan");
            setState(() {
              isEditable = !isEditable;
            });
          } else {
            // ignore: use_build_context_synchronously
            customDialog(
                context, "Tidak berhasil", "Tidak ada data yang dirubah");
          }
        }
      }
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
            fillColor: AppColor.formcolor),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      SizedBox(
                          height: 190,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/profile_bg.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          )),
                      Container(
                        width: double.infinity,
                        height: 220,
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 100,
                              child: imageUrl.isEmpty && photo == null
                                  ? Image.asset("assets/images/profile.png")
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        image: DecorationImage(
                                          image: photo != null
                                              ? FileImage(photo!)
                                              : NetworkImage(imageUrl)
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      height: 100,
                                      width: 100,
                                    ),
                            ),
                            if (isEditable)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () async {
                                    File? result =
                                        await showImagePicker(context);
                                    if (result != null) {
                                      setState(() {
                                        photo = result;
                                      });
                                    }
                                  },
                                  child: const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColor.tertiary,
                                    child: Icon(
                                      Icons.camera,
                                      color: AppColor.secondary,
                                      size: 20,
                                    ),
                                  ).animate(target: isEditable ? 1 : 1).shake(),
                                ),
                              )
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 95,
                        alignment: Alignment.bottomCenter,
                        child: const Text(
                          'PROFILE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                      const CustomBackButton(color: AppColor.quaternary),
                      Positioned(
                        right: 30,
                        top: 50,
                        child: CircleAvatar(
                          backgroundColor: isEditable
                              ? AppColor.tertiary
                              : Colors.transparent,
                          radius: 28,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isEditable = !isEditable;
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ).animate(target: isEditable ? 0 : 0).fadeOut(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Nama tidak boleh kosong!";
                          }
                          return null;
                        },
                        initialValue: name,
                        enabled: isEditable,
                        onSaved: (newValue) => name = newValue!,
                        key: const ValueKey('name'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Email'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        enabled: false,
                        initialValue: email,
                        key: const ValueKey('email'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('No Telepon'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        enabled: isEditable,
                        initialValue: number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Wajib diisi";
                          } else if (value.isNotEmpty &&
                              int.tryParse(value) != null &&
                              value.length < 8) {
                            return "Tolong isi dengan no telepon yang valid";
                          }
                          return null;
                        },
                        onSaved: (newValue) => number = newValue!,
                        key: const ValueKey('number'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Alamat'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        onSaved: (newValue) => address = newValue!,
                        initialValue: address,
                        enabled: isEditable,
                        key: const ValueKey('address'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (userData.role == UserRole.dokter)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deskripsi'),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              onSaved: (newValue) => address = newValue!,
                              initialValue: cAuth.deskripsi,
                              validator: (value) {
                                if (userData.role == UserRole.dokter &&
                                    value!.isEmpty) {
                                  'Deskripsi tidak boleh kosong';
                                }
                                return null;
                              },
                              enabled: isEditable,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5)),
                              key: const ValueKey('deskripsi'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Harga'),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              onSaved: (newValue) => address = newValue!,
                              initialValue: cAuth.harga.toString(),
                              enabled: isEditable,
                              key: const ValueKey('price'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mendaftar Sebagai'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  enabled: false,
                                  initialValue: role,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Semenjak'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  initialValue: since,
                                  enabled: false,
                                  key: const ValueKey('since'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: isEditable ? trySave : null,
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            color: isEditable ? AppColor.tertiary : Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                'SIMPAN',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isEditable
                                        ? AppColor.secondary
                                        : Colors.black),
                              ),
                            ),
                          ).animate(target: isEditable ? 0 : 1).shake(),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
