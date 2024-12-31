class User {
  String id; // Unique identifier for the user
  String name; // User's name
  String password; // User's password
  String phone; // User's phone number

  User(this.id,
      {required this.name, required this.password, required this.phone});

  // You can add a method to return a map of the user data, which might be useful
  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'phone': phone,
    };
  }

  // Optional: You can add a method for printing a user's information easily
  @override
  String toString() {
    return 'User{id: $id, name: $name, password: $password, phone: $phone}';
  }
}
