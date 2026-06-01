class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final ProfileAddress address;
  final String? referralCode;
  final String? photo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.address,
    this.referralCode,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'].toString(),
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String? ?? '',
        birthDate: j['birth_date'] as String? ?? '',
        address: j['address'] != null
            ? ProfileAddress.fromJson(j['address'] as Map<String, dynamic>)
            : ProfileAddress(department: '', commune: '', city: '', houseDetails: ''),
        referralCode: j['referralCode'] as String?,
        photo: j['photo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'birth_date': birthDate,
        'address': address.toJson(),
      };
}

class ProfileAddress {
  final String department;
  final String commune;
  final String city;
  final String houseDetails;
  final double? latitude;
  final double? longitude;

  ProfileAddress({
    required this.department,
    required this.commune,
    required this.city,
    required this.houseDetails,
    this.latitude,
    this.longitude,
  });

  factory ProfileAddress.fromJson(Map<String, dynamic> j) => ProfileAddress(
        department: j['department'] as String? ?? '',
        commune: j['commune'] as String? ?? '',
        city: j['city'] as String? ?? '',
        houseDetails: j['house_details'] as String? ?? '',
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'department': department,
        'commune': commune,
        'city': city,
        'house_details': houseDetails,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
