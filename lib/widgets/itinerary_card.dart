import 'package:flutter/material.dart';

class ItineraryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ItineraryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final car = data['car']['data'];
    final user = data['user']['data'];

    return Card(
      color: const Color(0xFF1E1E2E),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Nazwa Trasy", data['name']),
            _row("Ilość punktów", "${data['places_length']}"),
            _row("Kierowca", "${user['name']} (${user['email']})"),
            _row("Auto", "${car['registration_number']}, ${car['name']} (${car['brand']} ${car['model']})"),
            _row("Data", data['date']),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
