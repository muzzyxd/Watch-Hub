import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/getstart.dart';
import 'package:watchhub/home.dart';
import 'package:watchhub/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://mfatmpaoxobheujeecfl.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mYXRtcGFveG9iaGV1amVlY2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NTk0NTcsImV4cCI6MjA3MzUzNTQ1N30.oIl2D6OzmosDCnmXPii3nOR4kTivwBjYbqqOvUF0SFU",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch Hub – EXPERIENCE TIME DIFFERENTLY',
      theme: ThemeData(textTheme: GoogleFonts.jostTextTheme()),
      debugShowCheckedModeBanner: false,
      home: GetStart(),
    );
  }
}
