import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String awsLogoPath = '../logo.png';

  const WelcomePage({super.key}); // Replace with your logo path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 177, 254, 100),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                awsLogoPath,
                height: 300,
                width: 300,
              ),
              const SizedBox(height: 20),
              const Text(
                'FELINES OF TOMORROW',
                style: TextStyle(
                  color: Color.fromARGB(255, 30, 1, 1),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/SignInPage'); // Replace with your route name
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B60F9),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'GET STARTED >',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Add your "Login" button logic here
                  Navigator.pushNamed(
                      context, '/login'); // Replace with your route name
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('ALREADY HAVE AN ACCOUNT? LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
