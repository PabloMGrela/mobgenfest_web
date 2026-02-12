class Restaurant {
  final String name;
  final String type;
  final String category;
  final String address;
  final String rating;
  final String ratingCount;
  final String price;
  final String photo;
  final String distance;
  final String duration;
  final String phoneNumber;

  Restaurant({
    required this.name,
    required this.type,
    required this.category,
    required this.address,
    required this.rating,
    required this.ratingCount,
    required this.price,
    required this.photo,
    required this.distance,
    required this.duration,
    required this.phoneNumber,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      name: map['name'] ?? 'Unknown',
      type: map['type'] ?? 'Restaurante',
      category: map['category'] ?? 'Restaurantes',
      address: map['address'] ?? '',
      rating: map['rating'] ?? 'N/A',
      ratingCount: map['ratingCount'] ?? '0',
      price: map['price'] ?? '€',
      photo: map['photoUrl'] ?? '',
      distance: map['distance'] ?? '',
      duration: map['duration'] ?? '',
      phoneNumber: map['phone'] ?? '',
    );
  }
}
