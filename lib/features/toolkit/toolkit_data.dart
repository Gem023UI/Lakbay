import 'dart:convert';
import 'package:flutter/services.dart';

class EmergencyContact {
  final String label;
  final String number;

  const EmergencyContact({required this.label, required this.number});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      label: json['label'] as String? ?? '',
      number: json['number'] as String? ?? '',
    );
  }
}

class CountryToolkit {
  final String name;
  final String timezone;
  final int utcOffsetHours;
  final List<EmergencyContact> emergencies;
  final List<String> tipping;
  final List<String> etiquette;
  final List<String> checklist;

  const CountryToolkit({
    required this.name,
    required this.timezone,
    required this.utcOffsetHours,
    required this.emergencies,
    required this.tipping,
    required this.etiquette,
    required this.checklist,
  });

  factory CountryToolkit.fromJson(Map<String, dynamic> json) {
    final rawEmergencies = json['emergencies'] as List<dynamic>? ?? [];
    return CountryToolkit(
      name: json['name'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      utcOffsetHours: json['utc_offset_hours'] as int? ?? 7,
      emergencies: rawEmergencies
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      tipping: (json['tipping'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      etiquette: (json['etiquette'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      checklist: (json['checklist'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class ToolkitDataService {
  Map<String, CountryToolkit>? _cache;

  Future<CountryToolkit> getToolkit(String countryCode) async {
    if (_cache == null) {
      final jsonStr = await rootBundle.loadString('assets/data/countries.json');
      final Map<String, dynamic> map = json.decode(jsonStr) as Map<String, dynamic>;
      _cache = map.map(
        (key, value) => MapEntry(
          key.toUpperCase(),
          CountryToolkit.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return _cache![countryCode.toUpperCase()] ?? _cache!['TH']!;
  }
}
