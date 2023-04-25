import 'package:app/constant/appformat.dart';
import 'package:app/helper/customexception.dart';
import 'package:app/model/feedmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedController extends ChangeNotifier {
  String date = '';
  String schedule = '';

  List<FeedModel> _list = [];
  List<FeedModel> get list => _list;

  Future<void> fetchData() async {
    _list = [];
    final date = DateFormat('dd-MM-yyy').format(DateTime.now());
    final chickens = await FirebaseFirestore.instance
        .collection('feed_date')
        .where('date', isEqualTo: date)
        .get();

    if (chickens.docs.isEmpty) {
      final latestSchema = await FirebaseFirestore.instance
          .collection('feed_schema')
          .orderBy('date_created', descending: true)
          .limit(1)
          .get();
      await FirebaseFirestore.instance.collection('feed_date').add({
        "date": date,
        "isfeeded": [false, false],
        "schema_id": latestSchema.docs.first.id,
      });
    }
    final rawData = await FirebaseFirestore.instance
        .collection('feed_date')
        .orderBy('date', descending: true)
        .limit(7)
        .get();
    var schemaId = '';
    Map<String, dynamic> schemaData = {};
    for (var i in rawData.docs) {
      if (i['schema_id'] != schemaId) {
        schemaId = i['schema_id'];
        final data = await FirebaseFirestore.instance
            .collection('feed_schema')
            .doc(schemaId)
            .get();
        schemaData = data.data()!;
      }
      try {
        _list.add(FeedModel.fromJson(i.data(), schemaData, i.id));
      } catch (error) {
        print(error);
      }
    }
  }

  void fillAbsence() {
    final date = DateTime.now();
    final parsedFirst = AppFormat.currentDate(_list[0].time['first']);
    final parsedSecond = AppFormat.currentDate(_list[0].time['second']);

    if (date.isAfter(parsedFirst) &&
        date.isBefore(
          parsedFirst.add(
            const Duration(hours: 1),
          ),
        )) {
      if (_list[0].isfeeded[0] == true) {
        throw CustomException("Presensi pakan pertama telah terisi!");
      }
      absenceTrigger(0);
    } else if (date.isAfter(parsedSecond) &&
        date.isBefore(
          parsedSecond.add(
            const Duration(hours: 1),
          ),
        )) {
      if (_list[0].isfeeded[1] == true) {
        throw CustomException("Presensi pakan kedua telah terisi!");
      }
      absenceTrigger(1);
    } else {
      throw CustomException("Kamu sudah melewatkan jam presensi pakan!");
    }
  }

  void absenceTrigger(int index) async {
    _list[0].isfeeded[index] = true;
    await FirebaseFirestore.instance
        .collection('feed_date')
        .doc(_list[0].id)
        .update({'isfeeded': _list[0].isfeeded});

    notifyListeners();
  }
}