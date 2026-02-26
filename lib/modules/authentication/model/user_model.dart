import 'package:flutter/material.dart';

class UserModel {
  String username;
  String email;
  String password;
  String role; // Patient , // Doctor
  String specialization;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.specialization,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'specialization': specialization,

    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      specialization: map['specialization'],

    );
  }

}