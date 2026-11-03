class Person {
  final String id;
  final String name;
  final String department;
  final String email;

  const Person({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
  });

  factory Person.fromMap(String id, Map<String, dynamic> map) {
    return Person(
      id: id,
      name: (map['name'] ?? '') as String,
      department: (map['department'] ?? '') as String,
      email: (map['email'] ?? '') as String,
    );
  }
}
