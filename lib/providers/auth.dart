import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../modals/http_exception.dart';

class Auth with ChangeNotifier{

  String? _token;
  String? _userId;
  DateTime? _dateTime;
  Timer? _authTimer;

  bool get isAuth{
    return token != null;
  }

  String? get token{
    if( _dateTime!=null && _dateTime!.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }

  String? get userId{
    return _userId;
  }


  Future<void> _authenticate(String email, String password, String urlSegment) async{

    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAAgvlf7aQ6LwaFLZrVUZszAPzizAeU_Ws');
    try{
      final response = await http.post(url,body: json.encode({
        'email':email,
        'password':password,
        'returnSecureToken':true,
      }));

      final responseData  =jsonDecode(response.body);
      if(responseData['error']!=null){
        throw HttpException(responseData['error']['message'].toString());
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _dateTime = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'].toString())));
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token':_token,
        'userId':_userId,
        'expiryDate':_dateTime?.toIso8601String(),
      });
      prefs.setString('userData', userData);
    }catch(error){
      throw error;
    }

  }

  Future<void> signUp(String email,String password) async{

   return _authenticate(email, password, 'signUp');

  }

  Future<void> signIn( String email,String password ) async{

    return _authenticate(email, password, 'signInWithPassword');

  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData').toString()) as Map<String,dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _dateTime = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async{
    _userId = null;
    _token = null;
    _dateTime = null;
    if(_authTimer !=null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout(){

    if(_authTimer!=null){
      _authTimer!.cancel();
    }
    final timeToExpiry = _dateTime!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry),logout);
  }

}
