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

## F4: `AmityUIKitScope`

- `lib/amity_uikit.dart`: `AmityUIKitScope` provides the same blocs and providers as
  `AmityUIKitProvider`, without the nested `MaterialApp`. The host app sets
  `NavigationService.navigatorKey` on its own navigator and provides the UIKit `AppLocalizations`.

## F8: dependencies aligned with portal-flutter

- `permission_handler` `^12.0.1` → `^13.0.2`, `cached_network_image` `^3.4.1` → `^4.0.3`.
  (portal-flutter raises its own `package_info_plus` and `device_info_plus` to match ours.)
