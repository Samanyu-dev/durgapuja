class Client {
  final String id;
  final String name;
  final String phone;
  final String status;
  final String? photoUrl;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.photoUrl,
  });
}
