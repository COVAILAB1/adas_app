import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LoginPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('https://adas-backend.onrender.com/api/login'), // Replace with your IP or 10.0.2.2 for emulator
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      print('Raw response: ${response.body}');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success']) {
            final role = data['user']['role'];
            final userId = data['user']['id'].toString(); // ✅ this works
            // Ensure userId is int
            if (role == 'admin') {
              Navigator.pushNamed(context, '/admin');
            } else if (role == 'sub_admin') {
              Navigator.pushNamed(context, '/sub_admin');
            } else {
              Navigator.pushNamed(context, '/user', arguments: {'userId': userId});
            }
          } else {
            setState(() {
              _errorMessage = data['error'];
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid response format: $e\nResponse: ${response.body}';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to server: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}