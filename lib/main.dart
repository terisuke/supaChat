import 'package:flutter/material.dart';
import 'package:zundatalk/pages/top_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();// main関数をFutureに変更
  await dotenv.load(fileName: '.env');
  final String anonKey = dotenv.env['SUPABASE_ANON'] ?? '';
  final String projectUrl = dotenv.env['SUPABASE_URL'] ?? '';
  await Supabase.initialize(
   anonKey: anonKey, // プロジェクトAnon key
   url: projectUrl, // プロジェクトURL
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      title: 'ずんだとーく',
      home: const TopPage(),
    );
  }
}