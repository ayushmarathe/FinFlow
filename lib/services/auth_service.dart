// ignore_for_file: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finflow/expense_repository.dart';
import 'package:finflow/screens/add_expenses/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finflow/data/default_categories.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Initialize empty subcollections
        await userDoc.collection('expenses').doc('init').set({'init': true});
        await userDoc.collection('categories').doc('init').set({'init': true});
        await userDoc.collection('income').doc('init').set({'init': true});

        
      }
      
      return user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }


  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw("Sign In Error: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}