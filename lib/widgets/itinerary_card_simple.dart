import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../screens/place_details_screen.dart' show PlaceDetailsScreen;

class ItineraryCardSimple extends StatelessWidget {
  final Map<String, dynamic> data;

  const ItineraryCardSimple({super.key, required this.data});

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
            _row("Data", _formatDate(data['date'])),
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

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return date;
  }
}