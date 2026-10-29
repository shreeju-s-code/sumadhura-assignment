import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Primary & Accent
  static const Color primary = Color(0xFF142B4A);      
  static const Color primaryDark = Color(0xFF0D1E35);  
  static const Color tealAccent = Color(0xFF18A999);  
  static const Color tealLight = Color(0xFFE6F7F5);   

  // Surface & Neutrals
  static const Color background = Color(0xFFF4F7FB);   
  static const Color surface = Color(0xFFFFFFFF);      
  static const Color surfaceSubtle = Color(0xFFF8FAFC); 
  static const Color border = Color(0xFFDCE4ED);      
  static const Color borderFocused = Color(0xFF18A999);

  // Typography
  static const Color textPrimary = Color(0xFF142B4A);  
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);    
  static const Color textOnPrimary = Colors.white;

  // Status Colors (from spec reference)
  static const Color statusRegistered = Color(0xFF64748B); 
  static const Color statusCheckedIn = Color(0xFF15803D);  
  static const Color statusCheckedOut = Color(0xFF475569); 
  static const Color statusDestructive = Color(0xFFB91C1C);
  static const Color statusAttention = Color(0xFFB45309);  

  // Soft Status Backgrounds for Badges & Chips
  static const Color bgRegistered = Color(0xFFF1F5F9);
  static const Color bgCheckedIn = Color(0xFFDCFCE7);
  static const Color bgCheckedOut = Color(0xFFF1F5F9);
  static const Color bgDestructive = Color(0xFFFEE2E2);
  static const Color bgAttention = Color(0xFFFEF3C7);
}
