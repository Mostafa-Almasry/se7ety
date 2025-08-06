class DoctorModel {
  String name;
  String image;
  String specialisation;
  double rating;
  String email;
  String phone1;
  String phone2;
  String bio;
  String openHour;
  String closeHour;
  String address;
  String uid;

  DoctorModel({
    required this.name,
    required this.image,
    required this.specialisation,
    required this.rating,
    required this.email,
    required this.phone1,
    required this.phone2,
    required this.bio,
    required this.openHour,
    required this.closeHour,
    required this.address,
    required this.uid,
  });

  DoctorModel copyWith({
    String? name,
    String? image,
    String? specialisation,
    double? rating,
    String? email,
    String? phone1,
    String? phone2,
    String? bio,
    String? openHour,
    String? closeHour,
    String? address,
    String? uid,
  }) {
    return DoctorModel(
      name: name ?? this.name,
      image: image ?? this.image,
      specialisation: specialisation ?? this.specialisation,
      rating: rating ?? this.rating,
      email: email ?? this.email,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      bio: bio ?? this.bio,
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
      address: address ?? this.address,
      uid: uid ?? this.uid,
    );
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      name: json['name'] as String? ?? 'Unknown Doctor',
      image: json['image'] as String? ?? '',
      specialisation: json['specialisation'] as String? ?? 'غير محدد',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      email: json['email'] as String? ?? '',
      phone1: json['phone1'] as String? ?? '',
      phone2: json['phone2'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      openHour: json['openHour'] as String? ?? '9:00 ص',
      closeHour: json['closeHour'] as String? ?? '3:00 م',
      address: json['address'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['specialisation'] = specialisation;
    data['rating'] = rating;
    data['email'] = email;
    data['phone1'] = phone1;
    data['phone2'] = phone2;
    data['bio'] = bio;
    data['openHour'] = openHour;
    data['closeHour'] = closeHour;
    data['address'] = address;
    data['uid'] = uid;
    return data;
  }
}
