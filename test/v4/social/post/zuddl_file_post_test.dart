import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/generated/app_localizations.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_file.dart';
import 'package:amity_uikit_beta_service/v4/utils/zuddl_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// [ZUDDL] File posts, as native iOS.
void main() {
  group('icon', () {
    test('by extension, as iOS AmityFileExtension', () {
      expect(zuddlFileIcon('pdf', null), 'assets/Icons/zuddl_ic_file_pdf.svg');
      expect(
          zuddlFileIcon('.DOCX', null), 'assets/Icons/zuddl_ic_file_doc.svg');
      expect(zuddlFileIcon('xlsx', null), 'assets/Icons/zuddl_ic_file_xls.svg');
      expect(zuddlFileIcon('pptx', null), 'assets/Icons/zuddl_ic_file_ppt.svg');
    });

    test('else by MIME type, else the default', () {
      expect(zuddlFileIcon('heic', 'image/heic'),
          'assets/Icons/zuddl_ic_file_img.svg');
      expect(zuddlFileIcon('m4a', 'audio/mp4'),
          'assets/Icons/zuddl_ic_file_audio.svg');
      expect(zuddlFileIcon('mkv', 'video/x-matroska'),
          'assets/Icons/zuddl_ic_file_mov.svg');
      expect(
          zuddlFileIcon('key', null), 'assets/Icons/zuddl_ic_file_default.svg');
    });
  });

  test('sizes use decimal units, as iOS ByteCountFormatter', () {
    expect(zuddlFileSize(512), '512 bytes');
    expect(zuddlFileSize(345000), '345 KB');
    expect(zuddlFileSize(1200000), '1.2 MB');
    expect(zuddlFileSize(1000000), '1 MB');
    expect(zuddlFileSize(1230000000), '1.23 GB');
  });

  AmityPost filePost(int i) => AmityPost(postId: 'p$i')
    ..data = (FileData(postId: 'p$i')
      ..fileInfo = AmityFile(AmityFileProperties()
        ..name = 'agenda-$i.pdf'
        ..ext = 'pdf'
        ..size = '1200000'
        ..fileUrl = 'https://files/$i'));

  Future<void> pump(WidgetTester tester, List<AmityPost> posts,
          {VoidCallback? onViewAll}) =>
      tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            child: PostContentFile(
              posts: posts,
              theme: lightTheme.toThemeColor(),
              onViewAll: onViewAll,
            ),
          ),
        ),
      ));

  testWidgets('a row shows the name and size', (tester) async {
    await pump(tester, [filePost(1)]);
    expect(find.text('agenda-1.pdf'), findsOneWidget);
    expect(find.text('1.2 MB'), findsOneWidget);
  });

  testWidgets('the feed shows five files, then View all files', (tester) async {
    var tapped = false;
    await pump(tester, [for (var i = 0; i < 7; i++) filePost(i)],
        onViewAll: () => tapped = true);

    expect(find.textContaining('agenda-'), findsNWidgets(5));
    await tester.tap(find.text('View all files'));
    expect(tapped, isTrue);
  });

  testWidgets('post detail shows every file', (tester) async {
    await pump(tester, [for (var i = 0; i < 7; i++) filePost(i)]);
    expect(find.textContaining('agenda-'), findsNWidgets(7));
    expect(find.text('View all files'), findsNothing);
  });

  testWidgets('a file the SDK has not loaded yet is skipped, not a crash',
      (tester) async {
    await pump(tester, [AmityPost(postId: 'x')..data = FileData(postId: 'x')]);
    expect(tester.takeException(), isNull);
    expect(find.byType(InkWell), findsNothing);
  });
}

extension on AmityTheme {
  AmityThemeColor toThemeColor() => AmityThemeColor(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        baseColor: baseColor,
        baseInverseColor: baseInverseColor,
        baseColorShade1: baseColorShade1,
        baseColorShade2: baseColorShade2,
        baseColorShade3: baseColorShade3,
        baseColorShade4: baseColorShade4,
        alertColor: alertColor,
        backgroundColor: backgroundColor,
        backgroundShade1Color: backgroundShade1Color,
        highlightColor: highlightColor,
      );
}
