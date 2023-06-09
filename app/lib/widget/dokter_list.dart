import 'package:app/constant/app_color.dart';
import 'package:app/constant/app_format.dart';
import 'package:app/model/m_doctor.dart';
import 'package:flutter/material.dart';

class DokterListWidget extends StatelessWidget {
  const DokterListWidget({super.key, required this.data});
  final MDokter data;

  @override
  Widget build(BuildContext context) {
    final todayIndex = AppFormat.getCurrentDayIndex();
    final isOpen = data.ifCurrentlyOpen(todayIndex);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
          image: const DecorationImage(
              image: AssetImage("assets/images/requestlist_bg.png"),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed('/doctor-view', arguments: [data, true]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.nama,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                const SizedBox(
                  height: 5,
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: isOpen ? Colors.green : Colors.red,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      isOpen ? 'Sedang Buka' : 'Tutup',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColor.secondary,
              backgroundImage: data.imageUrl.isNotEmpty
                  ? NetworkImage(data.imageUrl)
                  : const AssetImage('assets/images/profile.png')
                      as ImageProvider,
            ),
          ],
        ),
      ),
    );
  }
}
