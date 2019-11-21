import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/userProfile.dart';
//import 'package:instagram_clone/blocs/instagrambloc.dart';

//From instagrambloc I can get the token

class UserProfileBloc extends ChangeNotifier {
  bool isReady = false;
  bool isLoggedIn = false;
  bool didLoginFail = false;
  bool didLoadFail = false;
  int userId;
  //List<Post> timeline = [];
  List<Post> user_posts = [];
  User userAccount;
  String token;

  UserProfileBloc(this.userId) {
    setup();
  }

  Future<void> setup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    token = (prefs.getString('token') ?? null);
    //print("User token: " + token);
    if (token != null) {
      isLoggedIn = true;
      notifyListeners();
      loadData();
    }
  }

  Future<void> loadData() async {
    // bool fetchedTimeline = await fetchTimeline();
    bool fetchedAccount = await fetchAccount();
    if (fetchedAccount) {
      print("User is ready");
      isReady = true;
      notifyListeners();
    } else {
      print("User is not ready");
      didLoadFail = true;
      notifyListeners();
    }
  }

  // Future<void> attemptLogin(String username, String password) async {
  //   print(
  //       "attempting login https://nameless-escarpment-45560.herokuapp.com/api/login?username=${username}&password=${password}");
  //   var response = await http.get(
  //       "https://nameless-escarpment-45560.herokuapp.com/api/login?username=${username}&password=${password}");
  //   if (response.statusCode == 200) {
  //     print("succeeded login");
  //     didLoginFail = false;
  //     Map<String, dynamic> jsonData = json.decode(response.body);
  //     token = jsonData["token"];
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('token', token);
  //     if (token != null) {
  //       isLoggedIn = true;
  //     }
  //     notifyListeners();
  //   } else {
  //     print(response.body);
  //     print("login did not succeed");
  //     didLoginFail = true;
  //     notifyListeners();
  //   }
  // }

  // Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove("token");
  //   isLoggedIn = false;
  //   notifyListeners();
  // }

  // Future<bool> fetchTimeline() async {
  //   var response = await http.get(
  //       "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts",
  //       headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
  //   if(response.statusCode == 200){
  //     List<dynamic> serverPosts = json.decode(response.body);
  //     for(int i = 0; i < serverPosts.length; i++){
  //       timeline.add(Post.fromJson(serverPosts[i]));

  //     }
  //     return true;
  //   }
  //   return false;
  // }

  Future<bool> fetchAccount() async {
    print("getting user data");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$userId",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      userAccount = User.fromJson(json.decode(response.body));

      print("getting user posts");
      var user_posts_response = await http.get(
          "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/$userId/posts",
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      if (user_posts_response.statusCode == 200) {
        print("successfully got user posts");
        List<dynamic> server_posts = json.decode(user_posts_response.body);
        user_posts = server_posts.map((p) => Post.fromJson(p)).toList();
        return true;
      }
    } else {
      print(response.body);
      print("user account load failed");
    }
    return false;
  }
}
