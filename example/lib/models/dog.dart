import 'package:flutter/material.dart';

@immutable
class Dog {
  final String url;

  const Dog(this.url);

  Dog.fromJson(Map<String, dynamic> json) : url = json['url'];

  Map<String, dynamic> toJson() => {
        'url': url,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dog && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
