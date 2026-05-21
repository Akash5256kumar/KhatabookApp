import 'package:equatable/equatable.dart';

/// A single named entity extracted by the backend MuRIL NER pipeline.
class MurilEntity extends Equatable {
  const MurilEntity({
    required this.type,
    required this.value,
    required this.score,
  });

  /// Entity type — one of: PERSON, AMOUNT, PRODUCT, DATE, QUANTITY.
  final String type;

  /// Surface form extracted from the input (e.g. "Raju", "500", "cement").
  final String value;

  /// Confidence score in [0, 1].
  final double score;

  factory MurilEntity.fromJson(Map<String, dynamic> json) => MurilEntity(
        type: json['type'] as String? ?? '',
        value: json['value'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [type, value, score];
}

/// MuRIL analysis attached to every assistant reply.
///
/// The backend MuRIL pipeline runs on the normalised user message and returns:
/// - language detection
/// - intent classification (9 Khatabook-specific intents)
/// - named-entity extraction (customer names, amounts, products, dates)
/// - the server-side normalised version of the input
///
/// All fields are lenient — the model may omit any field if confidence is low.
class MurilAnalysis extends Equatable {
  const MurilAnalysis({
    required this.detectedLanguage,
    required this.intent,
    required this.intentConfidence,
    required this.entities,
    required this.normalizedText,
  });

  /// BCP-47 language tag (e.g. "hi-Latn", "hi-Deva", "en").
  final String detectedLanguage;

  /// Top intent label (e.g. "ADD_SALE", "VIEW_BALANCE", "UNCLEAR").
  final String intent;

  /// Confidence score for [intent] in [0, 1].
  final double intentConfidence;

  /// Named entities extracted, sorted by score descending.
  final List<MurilEntity> entities;

  /// Input text after MuRIL's server-side normalisation pass.
  final String normalizedText;

  factory MurilAnalysis.fromJson(Map<String, dynamic> json) {
    final rawEntities = json['entities'] as List<dynamic>? ?? [];
    final entities = rawEntities
        .map((e) => MurilEntity.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return MurilAnalysis(
      detectedLanguage: json['detected_language'] as String? ?? 'hi-Latn',
      intent: json['intent'] as String? ?? 'UNCLEAR',
      intentConfidence:
          (json['intent_confidence'] as num?)?.toDouble() ?? 0.0,
      entities: entities,
      normalizedText: json['normalized_text'] as String? ?? '',
    );
  }

  /// Returns only entities with score ≥ [threshold] (default 0.70).
  List<MurilEntity> highConfidenceEntities({double threshold = 0.70}) =>
      entities.where((e) => e.score >= threshold).toList();

  @override
  List<Object?> get props => [
        detectedLanguage,
        intent,
        intentConfidence,
        entities,
        normalizedText,
      ];
}
