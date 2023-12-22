import 'dart:io';

import 'package:chat_application/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isSignup = false;

  var _email = '';
  var _password = '';
  File? _userImage;
  var _username = '';
  final _auth = FirebaseAuth.instance;
  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      _formKey.currentState!.save();
    } else {
      return;
    }
    if (_isSignup && _userImage == null) {
      return;
    }

    if (_isSignup) {
      try {
        final userCredentials = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_userImage!);
        final imageUrl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _username,
          'email': _email,
          'imageUrl': imageUrl,
        });
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed')));
      }
    } else {
      try {
        final userCredentials = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              width: _isSignup ? 200 : 400,
              child: const Image(image: AssetImage('assets/images/logob.png')),
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSignup)
                            ImagePickerWidget(
                              onPickImage: (image) {
                                _userImage = image;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Enter email address"),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue!;
                            },
                          ),
                          if (_isSignup)
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Enter username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 3) {
                                  return 'Enter a valid username (atleast 3 characters)';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _username = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Password"),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Minimum length must be 6';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(_isSignup ? 'Sign Up' : 'Log In'),
                          ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignup = !_isSignup;
                                });
                              },
                              child: Text(_isSignup
                                  ? 'Already have an account'
                                  : 'Create a new account'))
                        ],
                      )),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
