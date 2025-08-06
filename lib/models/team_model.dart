class Team {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String image;

  Team({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.image,
  });

  // Named constructor from Firestore map
 /* factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '', // default to empty string if not found
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      designation: map['designation'] ?? '',
      image: map['image'] ?? '',
    );
  }
  */
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'].toString(), // ✅ Fix here
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      designation: map['designation'] ?? '',
      image: map['image'] ?? '',
    );
  }
  Map<String, dynamic> toMapForSQL() {
    return {
      'id': id,  // include id here
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'image': image,
    };
  }


  // Convert to map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'image': image,
    };
  }


  // Add copyWith to clone and replace fields
  Team copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? designation,
    String? image,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      image: image ?? this.image,
    );
  }
}


