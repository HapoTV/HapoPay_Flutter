import 'package:flutter/material.dart';

class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String avatar;
  final double balance;
  final double limit;
  final double spent;
  final Color color;

  const ChildProfile({
    this.id = '',
    required this.name,
    required this.age,
    required this.avatar,
    required this.balance,
    required this.limit,
    required this.spent,
    required this.color,
  });
}
