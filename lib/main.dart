import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env doesn't exist, continue with default/empty values
    debugPrint('Warning: .env file not found. Using default configuration.');
  }

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // Continue app startup even if Supabase fails (for development)
  }

  runApp(const ProviderScope(child: StylemakeApp()));
}

class StylemakeApp extends StatelessWidget {
  const StylemakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stylemake v0.5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PlaceholderHomePage(),
    );
  }
}

class PlaceholderHomePage extends ConsumerStatefulWidget {
  const PlaceholderHomePage({super.key});

  @override
  ConsumerState<PlaceholderHomePage> createState() =>
      _PlaceholderHomePageState();
}

class _PlaceholderHomePageState extends ConsumerState<PlaceholderHomePage> {
  bool _isTestingConnection = true;
  bool _isConnected = false;
  int _stylesCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isTestingConnection = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.instance;

      if (!supabase.isInitialized) {
        setState(() {
          _isConnected = false;
          _errorMessage =
              supabase.initializationError ??
              'Supabase not initialized. Check your .env file.';
          _isTestingConnection = false;
        });
        return;
      }

      // Test connection
      final connected = await supabase.testConnection();

      if (connected) {
        // Get styles count
        final count = await supabase.getStylesCount();

        setState(() {
          _isConnected = true;
          _stylesCount = count;
          _isTestingConnection = false;
        });
      } else {
        setState(() {
          _isConnected = false;
          _errorMessage = 'Could not connect to database';
          _isTestingConnection = false;
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _errorMessage = e.toString();
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stylemake v0.5'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.factory,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Stylemake',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Garment Manufacturing Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Phase 1 - Database Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConnectionStatus(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    if (_isTestingConnection) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Testing database connection...'),
        ],
      );
    }

    if (_isConnected) {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text(
            '✓ Database Connected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Styles in database: $_stylesCount',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _testDatabaseConnection,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        const Text(
          '✗ Database Connection Failed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _testDatabaseConnection,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
