import '../util/json_util.dart';

/// A citable source for a piece of religious content (Qur'an verse, hadith,
/// fiqh reference). Every exercise in the V1 Islam module carries one so the
/// learner can always trace content back to its origin.
class SourceRef {
  const SourceRef({
    required this.collection,
    required this.reference,
    this.grading,
    this.text,
  });

  /// e.g. "Sahih al-Bukhari", "Qur'an", "Sahih Muslim".
  final String collection;

  /// e.g. "6324", "17:23", "Book of Manners #5197".
  final String reference;

  /// Authentication grading when applicable: "sahih", "hasan", "da'if (weak)".
  final String? grading;

  /// Quoted text (translation or excerpt) backing the item.
  final String? text;

  factory SourceRef.fromJson(Map<String, Object?> m) {
    return SourceRef(
      collection: reqStr(m, 'collection'),
      reference: reqStr(m, 'reference'),
      grading: optStr(m, 'grading'),
      text: optStr(m, 'text'),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'collection': collection,
        'reference': reference,
        if (grading != null) 'grading': grading,
        if (text != null) 'text': text,
      };

  /// Human-readable one-liner, e.g. "Sahih al-Bukhari 6324 (sahih)".
  String get display {
    final g = grading == null ? '' : ' ($grading)';
    return '$collection $reference$g';
  }

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      other is SourceRef &&
      other.collection == collection &&
      other.reference == reference &&
      other.grading == grading &&
      other.text == text;

  @override
  int get hashCode => Object.hash(collection, reference, grading, text);
}
