import 'package:app/constant/app_format.dart';
import 'package:app/model/m_jam_kerja.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MJamKerjaControllers extends ChangeNotifier {
  List<MJamKerja> _list = [];
  List<MJamKerja> get list => _list;

  Future<void> fetchData(String dokterId) async {
    try {
      _list = [];
      final result = await FirebaseFirestore.instance
          .collection('jam-kerja')
          .where('dokterId', isEqualTo: dokterId)
          .get();

      for (var i in result.docs) {
        _list.add(MJamKerja.fromJson(i.data(), i.id));
      }

      _list.sort((a, b) => (a.day).compareTo(b.day));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateData(List<MJamKerja> changedList) async {
    try {
      final List<MJamKerja> tempList = [];
      for (var i in changedList) {
        final isExist = _list.indexWhere((element) => element.day == i.day);

        if (isExist != -1) {
          if (i.berakhir != list[isExist].berakhir &&
              i.mulai != list[isExist].mulai) {
            await FirebaseFirestore.instance
                .collection('jam-kerja')
                .doc(list[isExist].jamKerjaId)
                .update({
              'mulai': AppFormat.dayTimeToString(i.mulai),
              'berakhir': AppFormat.dayTimeToString(i.berakhir)
            });
            tempList.add(
              MJamKerja(
                  jamKerjaId: list[isExist].jamKerjaId,
                  dokterId: list[isExist].dokterId,
                  mulai: i.mulai,
                  berakhir: i.berakhir,
                  day: i.day),
            );
            _list.removeAt(isExist);
          } else {
            tempList.add(list[isExist]);
            _list.removeAt(isExist);
          }
        } else {
          final result =
              await FirebaseFirestore.instance.collection('jam-kerja').add({
            'hari': i.day,
            'dokterId': FirebaseAuth.instance.currentUser!.uid,
            'mulai': AppFormat.dayTimeToString(i.mulai),
            'berakhir': AppFormat.dayTimeToString(i.berakhir)
          });
          tempList.add(MJamKerja(
              jamKerjaId: result.id,
              dokterId: FirebaseAuth.instance.currentUser!.uid,
              mulai: i.mulai,
              berakhir: i.berakhir,
              day: i.day));
        }
      }
      for (var i in _list) {
        await FirebaseFirestore.instance
            .collection('jam-kerja')
            .doc(i.jamKerjaId)
            .delete();
      }
      _list = tempList;
      _list.sort(
        (a, b) => (a.day).compareTo(b.day),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
