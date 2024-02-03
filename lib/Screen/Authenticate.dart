import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerRegistration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

//after sign up and fill in details, cannot log out

final _firebase = FirebaseAuth.instance;

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthenticatePageState();
  }
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredConfirmedPassword = '';

  var _LoginEmailController = TextEditingController();
  var _SignUpEmailController = TextEditingController();
  var _LoginPasswordController = TextEditingController();
  var _SignUpPasswordController = TextEditingController();
  var _SignUpConfirmPasswordController = TextEditingController();

  var _isAuthenticating = false;
  var _userType = 'Tutor'; // default value
  final List<String> _userTypes = ['Tutor Seeker', 'Tutor'];

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      //show error msg...
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final UserCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final UserCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        /*
        FirebaseFirestore.instance
            .collection('users')
            .doc(UserCredentials.user!.uid)
            .set({
          'email': _enteredEmail,
          'user type': _userType,
        });
        */
        FirebaseFirestore.instance
            .collection(_userType)
            .doc(UserCredentials.user!.uid)
            .set({
          'Email': _enteredEmail,
          'UserType': "New "+_userType,
        });

      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EduMate',
          style: TextStyle(
            color: Color(0xFF795ED9),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/s.png', // Replace with your asset image path
                width: double.infinity,
                height: 250.0,
                fit: BoxFit.cover,
              ),
              Row(
                mainAxisSize: MainAxisSize
                    .min, // Use min to prevent the Row from expanding to the full width of the screen
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = true;
                        _LoginEmailController.clear();
                        _SignUpEmailController.clear();
                        _LoginPasswordController.clear();
                        _SignUpPasswordController.clear();
                        _SignUpConfirmPasswordController.clear();
                        _form.currentState?.reset();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: _isLogin
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.white, // Button color
                      onPrimary: _isLogin
                          ? Color(0xFF795ED9)
                          : Colors.black, // Text color
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      side: BorderSide(color: Colors.white), // Border color
                    ),
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = false;
                        _LoginEmailController.clear();
                        _SignUpEmailController.clear();
                        _LoginPasswordController.clear();
                        _SignUpPasswordController.clear();
                        _SignUpConfirmPasswordController.clear();
                        _form.currentState?.reset();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: !_isLogin
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.white, // Button color
                      onPrimary: !_isLogin
                          ? Color(0xFF795ED9)
                          : Colors.black, // Text color
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      side:
                          const BorderSide(color: Colors.white), // Border color
                    ),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              DropdownButtonFormField<String>(
                                value: _userType,
                                decoration: InputDecoration(
                                  labelText: 'I am a',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                items: _userTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _userType = newValue!;
                                  });
                                },
                              ),
                            SizedBox(height: 16),
                            if (!_isLogin)
                              TextFormField(
                                controller: _SignUpEmailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                            if (_isLogin)
                              TextFormField(
                                controller: _LoginEmailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                            SizedBox(height: 20),
                            if (!_isLogin)
                              TextFormField(
                                controller: _SignUpPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredPassword = value!;
                                },
                              ),
                            if (_isLogin)
                              TextFormField(
                                controller: _LoginPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredPassword = value!;
                                },
                              ),
                            SizedBox(height: 20),
                            if (!_isLogin)
                              TextFormField(
                                controller: _SignUpConfirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  if (_SignUpPasswordController.text != value) {
                                    return 'Password does not match';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredConfirmedPassword = value!;
                                },
                              ),
                            if (!_isLogin) SizedBox(height: 12),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Sign Up'),
                              ),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
