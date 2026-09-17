import 'package:flutter/material.dart';

enum AppDestination {
  map('地圖', Icons.map_outlined),
  backpack('背包', Icons.backpack_outlined),
  journal('紀錄', Icons.menu_book_outlined);

  const AppDestination(this.label, this.icon);
  final String label;
  final IconData icon;
}
