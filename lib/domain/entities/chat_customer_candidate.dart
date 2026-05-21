import 'package:equatable/equatable.dart';

/// A customer match returned by the backend when the user's message is ambiguous.
class ChatCustomerCandidate extends Equatable {
  const ChatCustomerCandidate({
    required this.id,
    required this.name,
    this.phone,
    required this.pending,
    this.similarityScore,
  });

  final int id;
  final String name;
  final String? phone;

  /// Outstanding balance owed by this customer.
  final double pending;

  /// MuRIL embedding cosine similarity between the user's query and this
  /// customer's name — in [0, 1]. Null when the backend did not run MuRIL.
  final double? similarityScore;

  factory ChatCustomerCandidate.fromJson(Map<String, dynamic> json) {
    return ChatCustomerCandidate(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      pending: (json['pending'] as num?)?.toDouble() ?? 0.0,
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, phone, pending, similarityScore];
}
