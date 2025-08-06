class User {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String username;
  final String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.password,
  });

  // Convert User object to Map (for saving to storage)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  // Convert Map to User object (for loading from storage)
  //for verification this would read the data
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
    );
  }
}
