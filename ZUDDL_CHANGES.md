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

## Fix: user avatars use the Zuddl profile photo

Zuddl stores the attendee's photo as Amity `avatarCustomUrl`; `avatarUrl` is only set for a file
uploaded to Amity, so every avatar showed initials. Both natives read the custom URL (Android
`AmityPostHeaderViewHolder.kt:50`, `AmityPostCommentView.kt:67`; iOS `AmityPostModel.swift:304`).

- `lib/v4/utils/zuddl_avatar.dart`: `AmityUser.zuddlAvatarUrl`, the custom URL, else `avatarUrl`.
- Every user avatar reads it: post header, comments (`AmityUserImage`), comment box, mentions,
  members, follow lists, pending posts, profile header and edit page, community setup.
- The full-screen profile photo viewer still opens only an Amity file (it adds `?size=large`).
- No photo: `ZuddlInitialsAvatar`, up to two initials in `secondary_color` on `primary_color`, text
  half the circle's width. It matches portal-flutter's speaker avatar in session details, instead of
  Amity's one-letter disc. Used by `AmityUserAvatar` and `AmityUserImage`.
- Test: `test/v4/utils/zuddl_avatar_test.dart`.

## F6: parity hides (MOB-1822)

What attendees can do matches the native apps.

- `assets/config/config.json`: live-stream, clip and poll creation off (story creation was already
  off), as native iOS's composer. Text, image and video stay on; existing polls, live streams and
  clips still show. (Poll off: owner decision 2026-11-25, reversing spec Q1.)
- `amity_community_profile_page.dart`: the create button is native iOS's pencil
  (`assets/Icons/zuddl_ic_create_post.svg`, traced from portal-ios ASC-UIKit `icon_create_post.pdf`),
  24 pt in `secondary_color`, and opens the post composer straight away when post is the only choice, as
  natives do. With more choices it still shows the menu.
- `lib/v4/utils/zuddl_flags.dart`: `zuddlOpensUserProfiles` and `zuddlOpensMemberList`, both false.
  - Every `goToUserProfilePage` behaviour returns early (post content, comments, reactions through
    post content, pending posts, members, follow lists, search, global feed), and so does the
    mention tap in `post_content_text.dart`. As iOS 112d83a, 6ca68c3, f2ae9ba. The user profile's
    pending, blocked and follow pages are only reachable from a profile, so they are gone too.
  - `community_info_view.dart`: the member count is not a link (iOS 96d9dce).
- `amity_community_profile_page.dart`: the pending-posts banner shows to moderators only (iOS 84c226e).
- Already true in 4.22, no patch: no share action (the share button is never shown); no options
  menu or back button on the cover (F6 part, earlier).
- Test: `test/v4/zuddl_parity_test.dart`.

## F7: community description HTML

- `lib/v4/utils/zuddl_html.dart`: `zuddlHtmlToPlainText`, ported from iOS `htmlToPlainText`
  (5b66f3b, e54bdb2). Known tags only; script and style bodies dropped; entities decoded.
- `community_header_component.dart`: the description shows through it.
- Test: `test/v4/utils/zuddl_html_test.dart`.

## File posts (MOB-1822)

Native iOS posts and shows files; the 4.22 UIKit did neither, so a native file post showed only
its text.

- Show: `lib/v4/social/post/common/post_children_content_file.dart` (`PostContentFile`), used by
  `post_item.dart` (feed: first five files, then "View all files" opens the post) and
  `post_children_content.dart` (post detail: every file). A row is the type icon, name and size;
  a tap opens the file. iOS downloads it and offers to save instead. `fileInfo` is read guarded,
  because the SDK leaves it unset until the file is cached.
- Attach: an Attachment option (`zuddl_ic_attach_button.svg`, paperclip from portal-ios
  `icon_attach.pdf`) in both composer bars, last in the row and before Video in the list, as iOS.
  `pickDocuments` in `post_composer_file_picker.dart`: system file picker, up to 10 files, each up
  to 1 GB (iOS `AmityFilePicker`), with iOS's two alerts. Upload with `uploadFile`
  (`PostComposerSelectDocumentEvent`), a row per file with progress in the composer, and
  `dataTypeSelector.file(...)` to post. Camera, Photo and Video hide once a file is picked, as
  images and videos already do.
- `lib/v4/utils/zuddl_file.dart`: limits, the extension/MIME to icon map and the size format,
  ported from iOS. Icons `assets/Icons/zuddl_ic_file_*.svg` are converted from portal-ios
  ASC-UIKit `icon_file_*.pdf`.
- Composer sheet `maxBottomSheetSize` 0.32 → 0.38 so the fourth row fits.
- No camera (a simulator): `post_camera_screen.dart` says "Camera isn't available" instead of
  closing silently.
- New `lib/l10n/intl_en.arb` strings (`zuddl_*`), generated files updated.
- Test: `test/v4/social/post/zuddl_file_post_test.dart`.

## F5: feed header hook (MOB-1823)

- `amity_community_profile_page.dart`: optional `zuddlFeedHeader`, shown as a sliver between the
  pinned tabs and the posts on the Timeline tab only. portal-flutter puts the event's
  scroll-with-page banner there, as iOS (`1f96d55`, `c79fa55`). With none, nothing changes.
- Also `zuddlFeedFooter`: the last Timeline row, in a `SliverFillRemaining` so a short feed shows it
  at the bottom and a long one after the last post. For a scroll-with-page BOTTOM banner.
