import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// [ZUDDL] F1: host colours from applyZuddlTheme win on both read paths,
// whether they arrive before or after the config load.
void main() {
  late AmityTokenTable table;
  final primaryToken = AmityColorToken.values
      .firstWhere((t) => t.themeKeyLight == 'primary_color');
  final repo = ConfigRepository();

  Map<String, dynamic> config() => {
        'preferred_theme': 'light',
        'theme': {
          'light': {'primary_color': '#1054DE', 'base_shade4_color': '#EBECEF'},
          'dark': {'primary_color': '#1054DE', 'base_shade4_color': '#292B32'},
        },
      };

  const host = {
    'primary_color': '#FF532D',
    'background_color': '#F5F5F5',
    'comment_background': '#ABCDEF',
  };

  setUpAll(() {
    table = AmityTokenResolver.tableFromJson(jsonDecode(
        File('assets/tokens/amity-uikit-design-tokens.json')
            .readAsStringSync()) as Map<String, dynamic>);
  });

  setUp(() {
    repo.preferredThemeNotifier.value = null;
    repo.applyZuddlTheme(light: const {}, dark: const {});
  });

  void expectHostColours() {
    final theme = repo.getTheme(null);
    expect(theme.primaryColor, const Color(0xFFFF532D));
    expect(theme.backgroundColor, const Color(0xFFF5F5F5));
    expect(theme.commentBackgroundColor, const Color(0xFFABCDEF));
    expect(repo.resolveToken(null, primaryToken), const Color(0xFFFF532D));
  }

  testWidgets('host colours applied before the config load still win',
      (tester) async {
    repo.applyZuddlTheme(light: host, dark: host);
    repo.debugSetConfig(config(), tokenTable: table);

    expectHostColours();
  });

  testWidgets('host colours applied after the config load win', (tester) async {
    repo.debugSetConfig(config(), tokenTable: table);
    expect(repo.getTheme(null).primaryColor, const Color(0xFF1054DE));

    repo.applyZuddlTheme(light: host, dark: host);

    expectHostColours();
  });

  testWidgets(
      'comment background falls back to base shade 4 without a host value',
      (tester) async {
    repo.debugSetConfig(config(), tokenTable: table);

    expect(repo.getTheme(null).commentBackgroundColor, const Color(0xFFEBECEF));
  });

  testWidgets('each style reads its own host colours', (tester) async {
    repo.debugSetConfig(config(), tokenTable: table);
    repo.applyZuddlTheme(
        light: const {'primary_color': '#111111'},
        dark: const {'primary_color': '#222222'});

    repo.setPreferredTheme(AmityThemeStyle.dark);
    expect(repo.getTheme(null).primaryColor, const Color(0xFF222222));
    repo.setPreferredTheme(AmityThemeStyle.light);
    expect(repo.getTheme(null).primaryColor, const Color(0xFF111111));
  });

  test('applying host colours notifies theme listeners', () {
    var calls = 0;
    void listener() => calls++;
    repo.themeChanges.addListener(listener);
    addTearDown(() => repo.themeChanges.removeListener(listener));

    repo.applyZuddlTheme(light: host, dark: host);

    expect(calls, 1);
  });
}
