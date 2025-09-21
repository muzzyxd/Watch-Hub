import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/home.dart';
import 'package:watchhub/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isObscure = true;

  Future<void> Regis() async {
    try {
      final check = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passController.text,
      );

      if (check.user != null) {
        // User created successfully
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Failed", textAlign: TextAlign.center),
            content: Text(e.toString(), textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close the dialog
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Color.fromARGB(255, 0, 105, 95)),
                ),
              ),
            ],
          );
        },
      );
    }
    emailController.clear();
    passController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/watchhub.jpeg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign up to Watch Hub",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email address",
                  hintText: "Enter your email address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: passController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: Regis,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Or"),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 80, 36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
