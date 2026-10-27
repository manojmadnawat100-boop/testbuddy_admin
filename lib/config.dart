import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

const kPrimary = Color(0xFF673AB7);
const storeName = "Raj and Son's Medical Store";
// Country code ke saath, bina + ke. Jaise 919876543210
const kWhatsApp = '91XXXXXXXXXX';

const firebaseOptions = FirebaseOptions(
  apiKey: 'PASTE_API_KEY',
  authDomain: 'PASTE_AUTH_DOMAIN',
  projectId: 'PASTE_PROJECT_ID',
  storageBucket: 'PASTE_STORAGE_BUCKET',
  messagingSenderId: 'PASTE_SENDER_ID',
  appId: 'PASTE_APP_ID',
);
