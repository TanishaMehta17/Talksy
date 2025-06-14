
  import 'dart:convert';

  class User {
    final String id;
    final String username;
    final String email;
    final String password;
    final String confirmpas;
    final String token;

    User({
      required this.id,
      required this.username,
      required this.email,
      required this.password,
      
      required this.confirmpas,
      required this.token,
    });

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
     
        'confirmpas': confirmpas,
        'token': token,
      };
    }

    factory User.fromMap(Map<String, dynamic> map) {
      return User(
        id: map['id'] ?? '',
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
     
        confirmpas: map['confirmpas'] ?? '',
        token: map['token'] ?? '',
      );
    }

    String toJson() => json.encode(toMap());

    factory User.fromJson(String source) => User.fromMap(json.decode(source));

    User copyWith({
      String? id,
      String? username,
      String? email,
      String? password,
      String? confirmpas,
      String? token,
    }) {
      return User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
  
        confirmpas: confirmpas ?? this.confirmpas,
        token: token ?? this.token,
      );
    }
  }
 