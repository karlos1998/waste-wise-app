import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const WasteWiseApp());
}

class WasteWiseApp extends StatelessWidget {
  const WasteWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadToken(),
      child: MaterialApp(
        title: 'WasteWise',
        theme: ThemeData.dark(),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) =>
          auth.isAuthenticated ? const HomeScreen() : LoginScreen(),
        ),
      ),
    );
  }
}
