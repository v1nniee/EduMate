import 'package:edumateapp/Screen/Authenticate.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorSetting extends StatelessWidget {
  const TutorSetting({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: const Color.fromARGB(255, 255, 116, 36),
            headerTitle: 'Settings',
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Change Password"),
                  leading: const Icon(
                      Icons.lock_outline), // Add an icon for visual indication
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                  tileColor: Colors
                      .grey[200], // Set the background color for the ListTile
                  shape: RoundedRectangleBorder(
                    // Optionally add a border radius
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Add more ListTiles for other settings here
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticatePage()),
      );
    }
  }

  Future<bool> reauthenticateUser(String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    AuthCredential credential = EmailAuthProvider.credential(
      email: user!.email!, // Assuming the user's email is not null
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      return true; // Re-authentication successful
    } catch (error) {
      return false; // Re-authentication failed
    }
  }

  void showPasswordMismatchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Mismatch"),
          content: Text(
              "The current password you entered does not match. Please try again."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showPasswordChangedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Changed"),
          content: Text("Your password has been changed."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 116, 36),
            headerTitle: 'Change Password',
          ),
          Expanded(
            // Use Expanded to fill the available space
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(
                    16.0), // Add padding around the ListView
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Current Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your current password";
                        }
                        return null;
                      },
                    ),
                  ),
                  // New Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a new password";
                        }
                        return null;
                      },
                    ),
                  ),
                  // Change Password Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Re-authenticate user with current password
                          bool isReauthenticated = await reauthenticateUser(
                              _passwordController.text);
                          if (isReauthenticated) {
                            try {
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null &&
                                  _passwordController.text.isNotEmpty) {
                                // After reauthentication, update the password
                                await user.updatePassword(
                                    _newPasswordController.text);
                                // Password updated successfully
                                Navigator.pop(context);
                              }
                            } on FirebaseAuthException catch (error) {
                              setState(() {
                                _errorMessage = error.message;
                              });
                            }
                            showPasswordChangedDialog();
                          } else {
                            // If reauthentication fails, show dialog
                            showPasswordMismatchDialog();
                          }
                        }
                      },
                      child: const Text("Change Password"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
