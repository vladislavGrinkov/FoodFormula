import 'package:flutter/material.dart';

List<Widget> generateStars(int raiting) {
  List<Widget> stars = [];
  for (var i = 1; i <= raiting; i++) {
    stars.add(
      const Icon(
        Icons.star,
        color: Colors.yellow,
      ),
    );
  }

  return stars;
}
