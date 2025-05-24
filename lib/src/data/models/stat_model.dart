import 'package:flutter/material.dart';

class StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    IconData getIconFromString(String iconName) {
      switch (iconName) {
        case 'fire':
          return Icons.local_fire_department;
        case 'trophy':
          return Icons.emoji_events;
        case 'clock':
          return Icons.timer;
        case 'target':
          return Icons.track_changes;
        default:
          return Icons.analytics;
      }
    }

    return StatItem(
      title: json['title'] ?? '',
      value: json['value']?.toString() ?? '0',
      subtitle: json['subtitle'] ?? '',
      icon: getIconFromString(json['icon'] ?? ''),
      color: Color(int.parse(json['color'] ?? '0xFF3B82F6', radix: 16)),
    );
  }

  Map<String, dynamic> toJson() {
    String getStringFromIcon(IconData icon) {
      if (icon == Icons.local_fire_department) return 'fire';
      if (icon == Icons.emoji_events) return 'trophy';
      if (icon == Icons.timer) return 'clock';
      if (icon == Icons.track_changes) return 'target';
      return 'analytics';
    }

    return {
      'title': title,
      'value': value,
      'subtitle': subtitle,
      'icon': getStringFromIcon(icon),
      'color': color.value.toRadixString(16),
    };
  }
}
