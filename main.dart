import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pexels-mikebirdy-120049.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Parking Booking',
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              _buildTextField('Username', usernameController, false),
              SizedBox(height: 20),
              _buildTextField('Password', passwordController, true),
              SizedBox(height: 40),
              _buildLoginButton(),
              SizedBox(height: 10),
              _buildCreateAccountButton(),
              Spacer(),
              Text(
                'Developed by Farrukh Mumtaz',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        'Login',
        style: TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return TextButton(
      onPressed: () {
        // Navigate to Create Account Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()),
        );
      },
      child: Text(
        'Create Account',
        style: TextStyle(
          fontSize: 16,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CreateAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Center(
        child: Text(
          'Create Account Page (Under Construction)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  html.File? _selectedFile;
  String? _imageUrl;
  String? _qrCodeDataUrl;

  Future<List<dynamic>> fetchParkingSlots() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/slots'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['available_slots'];
    } else {
      throw Exception('Failed to load parking slots');
    }
  }

  Future<void> bookParking(String slotId, String price) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Booking"),
          content: Text("Do you want to book this slot for $price?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'slot_id': slotId,
          'payment_info': price,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _qrCodeDataUrl =
              'data:image/png;base64,${data['receipt']['qr_code']}';
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Booking Confirmed'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Slot: ${data['receipt']['slot_id']}'),
                Text('Payment: ${data['receipt']['payment_info']}'),
                Image.network(_qrCodeDataUrl!),
                SizedBox(height: 8),
                Text(
                  'Developed by Farrukh Mumtaz',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorData['message'])));
      }
    }
  }

  Future<void> _pickImageAndBook() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      setState(() {
        _selectedFile = files[0];
      });

      final reader = html.FileReader();
      reader.readAsDataUrl(_selectedFile!);

      reader.onLoadEnd.listen((_) async {
        setState(() {
          _imageUrl = reader.result as String?;
        });

        bool emptySpotDetected = true;

        if (emptySpotDetected) {
          final slots = await fetchParkingSlots();
          final availableSlot = slots.firstWhere(
              (slot) => slot['status'] == 'Available',
              orElse: () => null);

          if (availableSlot != null) {
            await bookParking(availableSlot['slot_id'], "\$5");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('No available slots for instant booking.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No empty parking spot detected in the image.')));
        }
      });
    });
  }

  void _saveQrCode() {
    if (_qrCodeDataUrl != null) {
      final byteData = base64Decode(_qrCodeDataUrl!.split(',').last);
      final blob = html.Blob([byteData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'qr_code.png'
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Container(
        color:
            Color.fromARGB(255, 223, 225, 240), // Minimalist white background
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImageAndBook,
              child: Text('Instant Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 193, 184, 193),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchParkingSlots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var slots = snapshot.data!;
                    return ListView.builder(
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        var slot = slots[index];
                        return ListTile(
                          title: Text(slot['slot_id']),
                          subtitle: Text('Status: ${slot['status']}'),
                          tileColor: slot['status'] == 'Available'
                              ? Color.fromARGB(255, 173, 240, 175)
                              : Color.fromARGB(255, 183, 62, 74),
                          trailing: slot['status'] == 'Available'
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Price: \$5'),
                                    ElevatedButton(
                                      onPressed: () =>
                                          bookParking(slot['slot_id'], "\$5"),
                                      child: Text(
                                        'Book',
                                        style: TextStyle(
                                            color: Colors
                                                .black), // Change font color to black
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .blue, // Change button color to blue
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  }
                  return Center(child: Text('No data available'));
                },
              ),
            ),
            if (_qrCodeDataUrl != null) ...[
              ElevatedButton(
                onPressed: _saveQrCode,
                child: Text('Save QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
