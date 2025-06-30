class Staff {
  String id;
  String name;
  int age;
  String? docId;

  Staff({required this.id, required this.name, required this.age, this.docId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map, String docId) {
    return Staff(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      docId: docId,
    );
  }
}
