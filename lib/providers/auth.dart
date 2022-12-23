import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_expection.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    } else {
      return '';
    }
  }

  String get userId {
    if (_userId != null) {
      return _userId!;
    } else {
      return '';
    }
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBqtnq-tWVySgaEonzm84OIpxym5bMegYo');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      // print(userData);
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

// ********* autoLOGIN - START**********
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')!);
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }
  // ********* autoLOGIN - END**********

  Future<void> logout() async {
    print('logout called');
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }
}
