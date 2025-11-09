import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _saveLoginInfo = true;
  String _userName = 'Florence Chicken';
  String _userEmail = 'f.chicken@example.com';
  String _userBio = 'Book enthusiast and avid reader';

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get saveLoginInfo => _saveLoginInfo;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userBio => _userBio;

  SettingsProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _saveLoginInfo = prefs.getBool('saveLogin') ?? true;
    _userName = prefs.getString('userName') ?? 'Florence Chicken';
    _userEmail = prefs.getString('userEmail') ?? 'f.chicken@example.com';
    _userBio = prefs.getString('userBio') ?? 'Book enthusiast and avid reader';
    notifyListeners();
  }

  // Toggle notifications
  void toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    notifyListeners();
  }

  // Toggle save login info
  void toggleSaveLoginInfo(bool value) async {
    _saveLoginInfo = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveLogin', value);
    notifyListeners();
  }

  // Update profile information
  void updateProfile({String? name, String? email, String? bio}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (name != null) {
      _userName = name;
      await prefs.setString('userName', name);
    }
    
    if (email != null) {
      _userEmail = email;
      await prefs.setString('userEmail', email);
    }
    
    if (bio != null) {
      _userBio = bio;
      await prefs.setString('userBio', bio);
    }
    
    notifyListeners();
  }
}