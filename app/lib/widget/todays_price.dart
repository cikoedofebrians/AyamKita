import 'package:app/constant/app_format.dart';
import 'package:app/controller/c_harga_pasar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodayExpenses extends StatelessWidget {
  const TodayExpenses({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final priceController = Provider.of<CHargaPasar>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 2,
            color: Colors.black38,
            offset: Offset(2, 2),
          )
        ],
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/images/weatherbackground.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 20, left: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harga Ayam per hari ini :',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            AppFormat.currency(priceController.list.last.price),
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            priceController.getText(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/price-list'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('Lihat Histori'), Icon(Icons.navigate_next)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
