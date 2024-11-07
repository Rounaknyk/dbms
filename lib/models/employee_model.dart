import 'package:flutter/material.dart';

class EmployeeModel {
  final int id;
  final String email;
  final String password;
  final String name;
  final String phone;
  final dob;
  final int age;
  final String ssn;
  final String address;
  final double salary;
  final String role;
  final String? department;
  bool isManager;

  EmployeeModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.dob,
    required this.age,
    required this.ssn,
    required this.address,
    required this.salary,
    required this.role,
    this.department,
    this.isManager = false
  });

  // Convert Employee to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'dob': dob.toIso8601String(),
      'age': age,
      'ssn': ssn,
      'address': address,
      'salary': salary,
      'role': role,
      'department': department,
      'isManager': isManager
    };
  }

  // Create Employee from Map
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
        id: map['id'],
        email: map['email'],
        password: map['password'],
        name: map['name'],
        phone: map['phone'],
        dob: DateTime.parse(map['dob']),
        age: map['age'],
        ssn: map['ssn'],
        address: map['address'],
        salary: map['salary'],
        role: map['role'],
        department: map['department'],
        isManager: map['isManager']
    );
  }
}