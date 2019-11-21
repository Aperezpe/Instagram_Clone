class User{
    //   property :id, Serial
    // property :email, Text
    // property :bio, Text
    // property :profile_image_url, Text
    // property :password, Text
    // property :created_at, DateTime
    // property :role_id, Integer, default: 1
    int id;
    String email;
    String bio;
    String profile_image_url;
    DateTime created_at;
    
    User({this.id, this.email, this.bio, this.profile_image_url, this.created_at});

    factory User.fromJson(Map<String, dynamic> json){
      return User(id: json["id"], email: json["email"], bio: json["bio"], profile_image_url: json["profile_image_url"], created_at: DateTime.parse(json["created_at"]));
    }
}