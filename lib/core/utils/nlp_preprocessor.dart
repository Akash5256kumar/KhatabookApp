/// Script type detected in user input.
enum InputScript { devanagari, latin, mixed }

/// Client-side NLP pre-processor that runs before every chat API call.
///
/// Detects script, normalises Hinglish abbreviations + numeric shorthands,
/// and builds an enriched payload so the backend MuRIL pipeline starts with
/// clean, structured context.
class NlpPreprocessor {
  NlpPreprocessor._();

  static final RegExp _devanagariRe = RegExp(r'[ऀ-ॿ]');
  static final RegExp _latinRe = RegExp(r'[a-zA-Z]');

  // ── Script detection ────────────────────────────────────────────────────────

  /// Returns the dominant script type in [text].
  static InputScript detectScript(String text) {
    final hasDevanagari = _devanagariRe.hasMatch(text);
    final hasLatin = _latinRe.hasMatch(text);
    if (hasDevanagari && hasLatin) return InputScript.mixed;
    if (hasDevanagari) return InputScript.devanagari;
    return InputScript.latin;
  }

  /// Maps [script] to a BCP-47 language hint for the backend MuRIL model.
  static String scriptToLangHint(InputScript script) => switch (script) {
        InputScript.devanagari => 'hi-Deva',
        InputScript.mixed => 'hi-Latn',
        // Latin without Devanagari → most likely Hinglish in this domain.
        InputScript.latin => 'hi-Latn',
      };

  // ── Text normalisation ──────────────────────────────────────────────────────

  /// Expands common shorthands used in Hinglish business messages.
  ///
  /// Examples:
  ///   "5k"   → "5000"
  ///   "1.5L" → "150000"
  ///   "rs"   → "rupees"
  ///   "amt"  → "amount"
  static String normalize(String text) {
    var out = text.trim();

    // Numeric shorthands — must run before currency word replacements.
    out = out.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*[kK]\b'),
      (m) => (double.parse(m[1]!) * 1000).round().toString(),
    );
    out = out.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*[lL]\b'),
      (m) => (double.parse(m[1]!) * 100000).round().toString(),
    );

    // Currency abbreviations.
    out = out.replaceAll(RegExp(r'\brs\.?\b', caseSensitive: false), 'rupees');
    out = out.replaceAll(RegExp(r'₹\s*', caseSensitive: false), 'rupees ');

    // Common business abbreviations.
    out = out.replaceAll(RegExp(r'\bamt\b', caseSensitive: false), 'amount');
    out = out.replaceAll(RegExp(r'\bqty\b', caseSensitive: false), 'quantity');
    out = out.replaceAll(RegExp(r'\bpmt\b', caseSensitive: false), 'payment');
    out = out.replaceAll(RegExp(r'\budhr\b', caseSensitive: false), 'udhaar');
    out = out.replaceAll(RegExp(r'\brcvd\b', caseSensitive: false), 'received');
    out = out.replaceAll(RegExp(r'\bbal\b', caseSensitive: false), 'balance');
    out = out.replaceAll(RegExp(r'\btxn\b', caseSensitive: false), 'transaction');
    out = out.replaceAll(RegExp(r'\bno\.\b', caseSensitive: false), 'number');

    return out;
  }

  // ── Payload builder ─────────────────────────────────────────────────────────

  /// Builds the enriched request body for a text message.
  ///
  /// Returns a map with:
  /// - `message`   — normalised text (used by the backend LLM)
  /// - `raw_text`  — original user input (used by MuRIL for faithful NER)
  /// - `script`    — detected script name ("devanagari" | "latin" | "mixed")
  /// - `lang_hint` — BCP-47 hint for MuRIL language routing
  static Map<String, dynamic> buildPayload(String rawText) {
    final script = detectScript(rawText);
    return {
      'message': normalize(rawText),
      'raw_text': rawText,
      'script': script.name,
      'lang_hint': scriptToLangHint(script),
    };
  }
}
