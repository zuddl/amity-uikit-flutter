# Zuddl changes to the Amity Flutter UIKit

Base: Amity `4.22.0`. Patch ids (F1–F9) match the Feed tech spec in Linear.

## F2: chat removed

Portal uses Zuddl's own chat, so the UIKit chat module is gone.

- Deleted `lib/v4/chat/` and `test/v4/chat/`.
- Deleted the chat-only video pager `lib/v4/core/single_video_player/pager/`.
- Deleted `lib/v4/utils/media_permission_handler.dart` and `lib/v4/utils/media_util.dart`. They were
  only used by chat, and were the only users of `photo_manager` and `image_gallery_saver_plus`, so
  both packages are out of `pubspec.yaml`.
- `lib/amity_uikit.dart`: no chat cache clear on unregister.
- `lib/uikit_behavior.dart`: no chat behaviours.
- `lib/v4/utils/amity_image_viewer.dart`: own toast padding constant instead of the chat page's.
- `example/lib/main.dart`: chat pages removed.
- `test/v4/render_proof_test.dart`: chat reaction-row proof removed.

## F3: quiet setup, awaitable sign-out

- `lib/amity_uikit.dart` `setup`: `showLogs: false` (SDK logs can include user data). No
  `availableCameras()` scan, so sign-in never triggers a camera prompt. The post camera loads its
  own list. `AmityUIKit.cameras` stays empty, which is fine while story creation is off.
- `unRegisterDevice()` returns a `Future` and unregisters push before `logout()`.
- Locale debug `print`s removed.
- `registerDevice(context:)` is optional. It was unused, and portal-flutter signs in from its data layer.

## F8b: no local video thumbnails

- `flutter_video_thumbnail` removed: it ships for CocoaPods only, and portal-flutter builds iOS with
  Swift Package Manager only. `post_composer_bloc.dart`, `create_postV2_viewmodel.dart` and `story_draft_page.dart` skip the
  thumbnail; the UIKit already shows a placeholder without one. Posted videos use Amity's server
  thumbnail. (Owner decision 2026-11-25.)

## F4: `AmityUIKitScope`

- `lib/amity_uikit.dart`: `AmityUIKitScope` provides the same blocs and providers as
  `AmityUIKitProvider`, without the nested `MaterialApp`. The host app sets
  `NavigationService.navigatorKey` on its own navigator and provides the UIKit `AppLocalizations`.

## F8: dependencies aligned with portal-flutter

- `permission_handler` `^12.0.1` → `^13.0.2`, `cached_network_image` `^3.4.1` → `^4.0.3`.
- `file_picker` `12.0.0-beta.7` → `^13.4.1`. The beta pulled `win32` 6 and `dbus` 0.7, which clash with
  portal-flutter's `connectivity_plus`. v13 `pickFiles()` returns a list and always allows several
  files, so the 3 call sites changed (`post_composer_file_picker.dart`, `create_postV2_viewmodel.dart`).
  (portal-flutter raises its own `package_info_plus`, `device_info_plus` and `share_plus` to match.)

## F6 (part): community page back button

- `amity_community_profile_page.dart` and `element/community_cover_view.dart`: the back button uses
  `Navigator.maybePop`, so it does nothing when the community page is the first page of the host's
  navigator (the Feed tab). Hiding it there is slice 3.

## Fix: toast config not final

- `lib/v4/core/toast/amity_uikit_toast.dart`: `configProvider` and `uiConfig` are plain `late`, not
  `late final`. `didChangeDependencies` runs again when the config finishes loading or the theme
  changes; the second assignment threw `LateInitializationError` and the page showed a red error.
  Found on a real prod community with portal-flutter (2026-11-25).

## Fix: community header height

- `amity_community_profile_page.dart`: the collapsed header uses the real top inset
  (`MediaQuery.paddingOf(context).top`) instead of a hard-coded 44 (iOS) / 24 (Android). Inside
  portal-flutter's Feed the inset is 0, and the old value overflowed the bar by 44 px.

## F6 (part): community page like native

Requested 2026-11-25 after comparing with native iOS on prod.

- `assets/config/config.json`: `feature_flags.story` `create_enabled` and `view_story_tab_enabled`
  are false, so the Story ring is gone.
- `element/community_cover_view.dart`: the cover has no back or options ("…") button. The host's
  header has back; community settings stay hidden.
- `amity_community_profile_page.dart`: no collapsed community-name bar (`_zuddlShowsCollapsedBar`);
  the tab row is pinned at the top on scroll (`_PinnedTabsDelegate`, 48 pt).

## F1: host theme and font

portal-flutter sets the feed colours from the event theme, like iOS `AppManager.setupTheme`.

- `lib/v4/core/config_repository.dart`: `applyZuddlTheme(light:, dark:)` stores host colours apart
  from `_config`, so the first `loadConfig()` can't wipe them. `_applyConfig()` merges them over the
  config's `theme` block (`_effectiveTheme`), and both `getTheme()` and `resolveToken()` read that.
  `themeChanges` fires on a host colour or preferred style change.
- `lib/v4/utils/config_provider.dart`: listens to `themeChanges`, so new host colours re-theme the tree.
- `lib/v4/core/theme.dart`: `commentBackgroundColor`, from the `comment_background` key; falls back
  to `base_shade4`.
- `comment_item.dart`: the two comment bubble fills use `commentBackgroundColor`. Dividers and
  borders stay on `baseColorShade4`.
- `amity_community_profile_page.dart`: page background is `backgroundColor` (iOS `viewBackgroundColor`).
- Fonts: removed the hardcoded `fontFamily: 'SF Pro Text'` outside `story/` (`styles.dart`,
  comments, reactions, search, community feed and pin), so text inherits the host app's font.
- Test: `test/v4/core/theme/zuddl_host_theme_test.dart`.
