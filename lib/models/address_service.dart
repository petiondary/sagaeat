import 'package:flutter/material.dart';

class UserAddress {
  final String name;
  final String departement;
  final String commune;
  final String details;

  const UserAddress({
    required this.name,
    required this.departement,
    required this.commune,
    required this.details,
  });

  UserAddress copyWith({
    String? name,
    String? departement,
    String? commune,
    String? details,
  }) =>
      UserAddress(
        name: name ?? this.name,
        departement: departement ?? this.departement,
        commune: commune ?? this.commune,
        details: details ?? this.details,
      );
}

class AddressService {
  AddressService._();

  static final List<UserAddress> _addresses = [
    const UserAddress(
      name: "Kay",
      departement: "Ouest",
      commune: "Carrefour",
      details: "Monrepos, Kay Ble #42",
    ),
  ];

  static final ValueNotifier<int> countNotifier = ValueNotifier(1);

  static List<UserAddress> get addresses => List.unmodifiable(_addresses);
  static int get count => _addresses.length;
  static bool get canAdd => _addresses.length < 3;

  static void add(UserAddress address) {
    if (_addresses.length < 3) {
      _addresses.add(address);
      countNotifier.value = _addresses.length;
    }
  }

  static void update(int index, UserAddress address) {
    _addresses[index] = address;
    countNotifier.value = _addresses.length;
  }

  static void remove(int index) {
    _addresses.removeAt(index);
    countNotifier.value = _addresses.length;
  }
}
