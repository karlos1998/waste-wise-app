import 'package:flutter/material.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PlaceDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final place = data['place'];
    final company = data['company'];
    final date = data['date'];
    final contacts = company['contacts']['data'] as List;
    final designatedItinerary = data['designatedItinerary'];
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      appBar: AppBar(
        title: const Text("Szczegóły punktu"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1E1E2E),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${place['locality']}, ul. ${place['street']} ${place['building_number']}${place['local_number'] != null ? '/' + place['local_number'] : ''}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    _row("MPD", "${place['name']} (${place['identification_number']})"),
                    _row("NIP", company['nip']),
                    
                    const SizedBox(height: 8),
                    const Text(
                      "Kontakty",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...contacts.map((contact) => _row(
                      contact['name'],
                      contact['phone'] ?? 'Brak numeru',
                    )),
                    
                    const SizedBox(height: 8),
                    _row("Data odbioru", _formatDate(date)),
                    
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Oczekuje na odbiór",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Additional information about the itinerary
            Card(
              color: const Color(0xFF1E1E2E),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informacje o trasie",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _row("Nazwa trasy", designatedItinerary['name']),
                    _row("Kierowca", designatedItinerary['user']['data']['name']),
                    _row("Pojazd", "${designatedItinerary['car']['data']['brand']} ${designatedItinerary['car']['data']['model']} (${designatedItinerary['car']['data']['registration_number']})"),
                  ],
                ),
              ),
            ),
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