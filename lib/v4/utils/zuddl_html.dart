/// [ZUDDL] Community descriptions are written in Zuddl's rich-text editor, so
/// Amity can hand back raw HTML. Ported from iOS `String+Extension.swift`
/// `htmlToPlainText` (5b66f3b, e54bdb2).
library;

// Unknown tags stay text: "the <break>point" is prose, not markup.
const _knownTags =
    'a|b|blockquote|br|code|del|div|em|h[1-6]|hr|i|img|ins|li|mark|ol|p|pre|s|script|small|'
    'span|strike|strong|style|sub|sup|table|tbody|td|th|thead|tr|u|ul';

// `&amp;` goes last, so `&amp;lt;` becomes the text `&lt;` and not `<`.
const _namedEntities = [
  ('&nbsp;', ' '),
  ('&lt;', '<'),
  ('&gt;', '>'),
  ('&quot;', '"'),
  ('&apos;', "'"),
  ('&hellip;', '…'),
  ('&mdash;', '—'),
  ('&ndash;', '–'),
  ('&lsquo;', '‘'),
  ('&rsquo;', '’'),
  ('&ldquo;', '“'),
  ('&rdquo;', '”'),
  ('&amp;', '&'),
];

final _tag = RegExp('<\\s*/?\\s*(?:$_knownTags)(?:\\s[^<>]*)?/?\\s*>',
    caseSensitive: false);
final _entity =
    RegExp(r'&(#[0-9]+|#[xX][0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]{1,31});');

bool zuddlLooksLikeHtml(String s) => _tag.hasMatch(s) || _entity.hasMatch(s);

/// Plain text for display. Text that is not HTML only gets trimmed, so a typed
/// `<` or `&` is never changed.
String zuddlHtmlToPlainText(String s) {
  if (!zuddlLooksLikeHtml(s)) return s.trim();
  var t = s.replaceAll(
      RegExp(r'<\s*(script|style)\b[^<>]*>.*?<\s*/\s*\1\s*>',
          caseSensitive: false, dotAll: true),
      '');
  // The editor puts each block on its own line; that whitespace is not content.
  t = t.replaceAll(RegExp(r'>\s+<'), '><');
  t = t.replaceAll(
      RegExp(
          r'<\s*(?:br|hr)\s*/?\s*>|<\s*/\s*(?:p|div|li|ul|ol|tr|pre|blockquote|h[1-6])\s*>',
          caseSensitive: false),
      '\n');
  t = t.replaceAll(RegExp(r'<\s*/\s*(?:td|th)\s*>', caseSensitive: false), ' ');
  t = t.replaceAll(RegExp(r'<[^<>]+>'), '');
  t = _decodeEntities(t);
  t = t.replaceAll(RegExp(r'[ \t]*\n[ \t]*'), '\n');
  t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return t.trim();
}

String _decodeEntities(String s) {
  var t = s.replaceAllMapped(RegExp(r'&#([xX][0-9a-fA-F]+|[0-9]+);'), (m) {
    final body = m[1]!;
    final hex = body.toLowerCase().startsWith('x');
    final code =
        int.tryParse(hex ? body.substring(1) : body, radix: hex ? 16 : 10);
    if (code == null || code > 0x10FFFF) return m[0]!;
    return String.fromCharCode(code);
  });
  for (final (entity, text) in _namedEntities) {
    t = t.replaceAll(RegExp(RegExp.escape(entity), caseSensitive: false), text);
  }
  return t;
}
