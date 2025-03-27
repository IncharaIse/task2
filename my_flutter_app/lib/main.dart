import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _fetchedEmail = '';
  String _fetchedPassword = '';
  bool _isDataFetched = false;
  String _errorMessage = ''; // To display error message

  Future<void> submitData() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!email.endsWith('@gmail.com')) {
      setState(() {
        _errorMessage = 'Please enter a valid Gmail address';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/addUser'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        print('User added successfully');
        setState(() {
          _errorMessage = ''; // Clear error message on success
        });
      } else if (response.statusCode == 409) {
        // Handling duplicate email error
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Failed to add user';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to add user with status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _errorMessage = 'Error occurred: $e';
      });
    }
  }

Future<void> getUserDetails() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/getUserDetails'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fetchedEmail = data['email'] ?? ''; 
        _fetchedPassword = data['password'] ?? ''; // Ensure it's always a string
        _isDataFetched = true;
      });
    } else {
      print('Failed to fetch user details. Status code: ${response.statusCode}');
      setState(() {
        _errorMessage = 'Failed to fetch user details. Try again.';
      });
    }
  } catch (e) {
    print('Error occurred while fetching user details: $e');
    setState(() {
      _errorMessage = 'Error occurred: $e';
    });
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getUserDetails,
              child: Text('Get Details'),
            ),
            SizedBox(height: 20),
            _errorMessage.isNotEmpty
                ? Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  )
                : Container(),
            SizedBox(height: 20),
            _isDataFetched
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.lightBlueAccent,
                        child: Text(
                          'Email: $_fetchedEmail',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.lightGreen,
                        child: Text(
                          'Password: $_fetchedPassword',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
