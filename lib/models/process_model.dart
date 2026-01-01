import 'package:cloud_firestore/cloud_firestore.dart';

class ProcessModel {
  final String id;
  final String title;
  final String agency;
  final String description;
  final String tag;
  final String imageUrl;
  final double rating;
  final int reviews;

  ProcessModel({
    required this.id,
    required this.title,
    required this.agency,
    required this.description,
    required this.tag,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
  });

  // Convert Firebase Map to our Model
  factory ProcessModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProcessModel(
      id: doc.id,
      title: data['title'] ?? '',
      agency: data['agency'] ?? '',
      description: data['description'] ?? '',
      tag: data['tag'] ?? 'General',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
    );
  }

  // Convert Model back to Map to save to Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'agency': agency,
      'description': description,
      'tag': tag,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}