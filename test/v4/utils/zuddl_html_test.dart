import 'package:amity_uikit_beta_service/v4/utils/zuddl_html.dart';
import 'package:flutter_test/flutter_test.dart';

// [ZUDDL] Community descriptions: HTML from Zuddl's editor shows as plain text.
void main() {
  test('plain text is only trimmed, so a typed < or & survives', () {
    expect(zuddlHtmlToPlainText('  5 < 6 & 7 > 2  '), '5 < 6 & 7 > 2');
  });

  test('an unknown tag is prose, not markup', () {
    const s = 'the fourth edition of <break>point is here';
    expect(zuddlLooksLikeHtml(s), isFalse);
    expect(zuddlHtmlToPlainText(s), s);
  });

  test('blocks and breaks become lines; inline tags go', () {
    expect(
        zuddlHtmlToPlainText(
            '<p>Welcome to <strong>Catalyst</strong></p>\n<p>Day one<br/>Day two</p>'),
        'Welcome to Catalyst\nDay one\nDay two');
  });

  test('entities decode, and &amp; goes last', () {
    expect(
        zuddlHtmlToPlainText(
            '<p>Tom &amp; Jerry &#8217;s &lt;b&gt; &amp;lt;</p>'),
        'Tom & Jerry ’s <b> &lt;');
  });

  test('script and style bodies are dropped', () {
    expect(
        zuddlHtmlToPlainText(
            '<p>Hi</p><script>alert(1)</script><style>p{color:red}</style>'),
        'Hi');
  });

  test('more than one blank line collapses to one', () {
    expect(zuddlHtmlToPlainText('<p>A</p><p></p><p></p><p></p><p>B</p>'),
        'A\n\nB');
  });
}
