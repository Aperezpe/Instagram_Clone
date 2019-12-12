import 'package:http/http.dart' as http;
import 'dart:io';


class Comment {
  // property :id, Serial
  // #fill in the rest
  // property :caption, Text
  // property :image_url, Text
  // property :created_at, DateTime
  // property :user_id, Integer
  int id;
  int user_id;
  int post_id;
  String text;
  //DateTime created_at;


  Comment(
      {this.id, 
      this.user_id,
      this.post_id,
      this.text,
      });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json["id"],
        user_id: json["user_id"],
        post_id: json["post_id"],
        text: json["text"],
        //created_at: DateTime.parse(json["created_at"]),
        );
  }

  Future<bool> postComment(int id, String token, String input) async {
      if (input == '') {
        print("Comment is blank");
        return false;
      }

      var response = await http.post(
          "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/$id/comments?text=$input",
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      if (response.statusCode == 200) {

        print("Comment Successfully Added!");
        return true;

        // usersMap[postComments[i].user_id] =
        //     User.fromJson(jsonDecode(userResponse.body));
        //users.add(User.fromJson(jsonDecode(userResponse.body)));
      } else {
        print("There was a problem posting the comment");
        return false;
      }

      // setState(() {});
    }

  

}
