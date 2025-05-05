import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final int? itineraryId;
  final int? placeId;
  final String? date;

  const PlaceDetailsScreen({
    super.key, 
    this.data,
    this.itineraryId,
    this.placeId,
    this.date,
  }) : assert(data != null || (itineraryId != null && placeId != null && date != null), 
      'Either data or itineraryId, placeId, and date must be provided');

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _data = widget.data;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = ApiService(token: auth.token);

      final placeDetails = await api.fetchPlaceDetails(
        widget.itineraryId!,
        widget.placeId!,
        widget.date!,
      );

      setState(() {
        _data = placeDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Błąd ładowania danych: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1B),
        appBar: AppBar(
          title: const Text("Szczegóły punktu"),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1B),
        appBar: AppBar(
          title: const Text("Szczegóły punktu"),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text("Spróbuj ponownie"),
              ),
            ],
          ),
        ),
      );
    }

    final place = _data!['place'];
    final company = _data!['company'];
    final date = _data!['date'];
    final contacts = company['contacts']['data'] as List;
    final designatedItinerary = _data!['designatedItinerary'];

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

            // Create KPO button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F6EF7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showCreateKpoModal(context),
                child: const Text("Utwórz KPO", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateKpoModal(BuildContext context) {
    // Variables to store form values
    String? selectedWasteCode;
    String? selectedReceiver;
    final wasteAmountController = TextEditingController();

    // Get waste codes from place data
    final wasteCodes = _data!['place']['wasteCodes']['data'] as List;

    // Get available receivers from designated itinerary
    final receivers = _data!['designatedItinerary']['availableReceivers']['data'] as List;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          "Utwórz KPO",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waste code dropdown
              const Text(
                "Wybierz kod odpadu",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A40),
                    hint: const Text("Wybierz kod odpadu", style: TextStyle(color: Colors.white38)),
                    value: selectedWasteCode,
                    items: wasteCodes.map((wasteCode) {
                      return DropdownMenuItem<String>(
                        value: wasteCode['code'],
                        child: Text(
                          wasteCode['code'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedWasteCode = value;
                      // This is just a dialog, so we don't need to call setState
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Waste amount input
              const Text(
                "Masa odpadów [Kg]",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: wasteAmountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Podaj masę odpadów",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2A2A40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Receiver dropdown
              const Text(
                "Wybierz odbiorcę",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A40),
                    hint: const Text("Wybierz odbiorcę", style: TextStyle(color: Colors.white38)),
                    value: selectedReceiver,
                    items: receivers.map((receiver) {
                      return DropdownMenuItem<String>(
                        value: receiver['id'].toString(),
                        child: Text(
                          receiver['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedReceiver = value;
                      // This is just a dialog, so we don't need to call setState
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Zamknij"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F6EF7),
            ),
            onPressed: () {
              // For now, just close the dialog
              // In a real implementation, we would create the KPO here
              Navigator.of(context).pop();
            },
            child: const Text("Utwórz"),
          ),
        ],
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
