import 'dart:convert';

class Session {
  static String? usua_Id;
   
  static bool get isLoggedIn => usua_Id != null;

  static void login(String id) {
    usua_Id = id;
  }

  static void logout() {
    usua_Id = null;
  }
}