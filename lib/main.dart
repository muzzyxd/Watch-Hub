import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://sfylqbyotesylgqwrgcq.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmeWxxYnlvdGVzeWxncXdyZ2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MzExOTksImV4cCI6MjA3MjUwNzE5OX0.91c6C6V-ICwrZo2ueYWpztuWXIBninzm_zYBOAR8YcM",
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
      home: HomePage(),
    );
  }
}
