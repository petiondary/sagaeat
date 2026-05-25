class UserModel {
  final String id;
  final String name; // Lock nan pwofil la, pa ka modifye
  final String email;
  final String phone;
  final String birthDate;
  final UserAddress address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.address,
  });
}

class UserAddress {
  final String department;
  final String commune;
  final String city;
  final String houseDetails;
  final double? latitude;
  final double? longitude;

  UserAddress({
    required this.department,
    required this.commune,
    required this.city,
    required this.houseDetails,
    this.latitude,
    this.longitude,
  });
}
