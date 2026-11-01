
import 'package:flutter/material.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/CallPage/call_page.dart';
class Testcallscreen extends StatefulWidget {
  const Testcallscreen({super.key});

  @override
  State<Testcallscreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Testcallscreen> {
  String? username;
  String? email;
  String? phone;

  final TextEditingController _callIdController = TextEditingController();
  final TextEditingController _otherUserFcmTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService.getUserData();
    setState(() {
      username = userData['username'];
      email = userData['email'];
      phone = userData['phone'];
    });
  }
  void _joinCall() {
    final callId = _callIdController.text.trim();
    if (callId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Call ID!")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CallPage(callId: callId ,callType: '0',)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: username == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👤 Name: $username", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("📧 Email: $email", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("📱 Phone: $phone", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 32),
                    const Text("🎥 Video Call", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // TextField(
                    //   controller: _callIdController,
                    //   decoration: InputDecoration(
                    //     hintText: "Enter Call ID",
                    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _callIdController,
                      decoration: InputDecoration(
                        hintText: "Enter Other User FCM Token",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _joinCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Join a Call", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    // ElevatedButton(
                    //   onPressed: _joinCall,
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.pink,
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    //   ),
                    //   child: const Text("User List Call", style: TextStyle(fontSize: 16, color: Colors.white)),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
