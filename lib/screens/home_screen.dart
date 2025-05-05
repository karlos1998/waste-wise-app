import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/itinerary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final api = ApiService(token: auth.token);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      appBar: AppBar(
        title: const Text("Wyznaczone Trasy"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      drawer: _buildDrawer(),
      body: _selectedIndex == 0
          ? _buildAllItinerariesView(api)
          : _buildTodayItinerariesView(api),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E1E2E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F1B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.wb_auto_rounded, color: Color(0xFF5DFF5F), size: 48),
                  SizedBox(height: 16),
                  Text(
                    "Menu Nawigacji",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.white70),
              title: const Text(
                "Wszystkie trasy",
                style: TextStyle(color: Colors.white),
              ),
              selected: _selectedIndex == 0,
              selectedTileColor: const Color(0xFF4F6EF7).withOpacity(0.2),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.today, color: Colors.white70),
              title: const Text(
                "Trasy na dziś",
                style: TextStyle(color: Colors.white),
              ),
              selected: _selectedIndex == 1,
              selectedTileColor: const Color(0xFF4F6EF7).withOpacity(0.2),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAllItinerariesView(ApiService api) {
    return FutureBuilder<List<dynamic>>(
      future: api.fetchItineraries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Błąd ładowania danych", style: TextStyle(color: Colors.white)));
        }

        return ListView(
          children: snapshot.data!.map((e) => ItineraryCard(data: e)).toList(),
        );
      },
    );
  }

  Widget _buildTodayItinerariesView(ApiService api) {
    return FutureBuilder<List<dynamic>>(
      future: api.fetchTodayItineraries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Błąd ładowania danych", style: TextStyle(color: Colors.white)));
        }

        return ListView(
          children: snapshot.data!.map((e) => ItineraryCard(data: e)).toList(),
        );
      },
    );
  }
}
