import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../screens/place_details_screen.dart' show PlaceDetailsScreen;

class ItineraryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ItineraryCard({super.key, required this.data});

  // Helper methods
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

  Widget _countItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return date;
  }

  Widget _buildPlacesTable(BuildContext context, List places) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return _buildPlaceRow(context, place);
        },
      ),
    );
  }

  Widget _buildPlaceRow(BuildContext context, Map<String, dynamic> place) {
    final company = place['company']?['data'];
    final status = place['designatedItineraryReceiveStatus']?['data'];
    final isReceived = status != null && status['is_received'] == true;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company name
          Text(
            company?['name'] ?? place['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Address
          Text(
            "${place['locality']}, ul. ${place['street']} ${place['building_number']}${place['local_number'] != null ? '/' + place['local_number'] : ''}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Tags and status
          Row(
            children: [
              // BDO API tag
              if (place['access_token_generated'] == true)
                _buildTag("BDO API", Colors.green),

              const SizedBox(width: 8),

              // Contract status
              _buildTag("Umowa aktywna", Colors.blue),

              const Spacer(),

              // Status
              _buildTag(
                isReceived ? "Odebrano" : "Oczekuje na odbiór",
                isReceived ? Colors.green : Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Details button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPlaceDetails(context, place),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F6EF7),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text("Szczegóły"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPlaceDetails(BuildContext context, Map<String, dynamic> place) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final api = ApiService(token: auth.token);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        content: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final placeDetails = await api.fetchPlaceDetails(
        data['id'],
        place['id'],
        data['date'],
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to details screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlaceDetailsScreen(data: placeDetails),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Błąd ładowania danych")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = data['car']['data'];
    final user = data['user']['data'];
    final places = data['places']?['data'] as List?;

    // Count received and not received places
    int receivedCount = 0;
    int notReceivedCount = 0;

    if (places != null) {
      for (var place in places) {
        final status = place['designatedItineraryReceiveStatus']?['data'];
        if (status != null && status['is_received'] == true) {
          receivedCount++;
        } else if (status != null && status['is_received'] == false) {
          notReceivedCount++;
        }
      }
    }

    return Card(
      color: const Color(0xFF1E1E2E),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A40),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(data['date']),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Pojazd: ${car['brand']} ${car['model']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _countItem(
                        "Oczekujące punkty",
                        "${data['places_length']}",
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _countItem(
                        "Odebrane punkty",
                        "$receivedCount",
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _countItem(
                        "Nieodebrane punkty",
                        "$notReceivedCount",
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Places table
          if (places != null && places.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPlacesTable(context, places),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "Brak punktów w trasie",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
