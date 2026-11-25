# amity-uikit-flutter (Zuddl fork)

Zuddl's fork of Amity's Social+ Flutter UIKit (`AmityCo/Amity-Social-UIKit-Flutter-Opensource`).
Used only by `portal-flutter` for the event Feed. Design: Linear "Tech Spec: Portal Flutter Feed".

## Branches and tags

- Zuddl patches go directly on `main`. There is no separate patch branch.
- Amity's code: the `upstream` remote and Amity's release tags (`4.22.0`, ...).
- Zuddl releases are tags `<amity version>-zuddl.<n>`, e.g. `4.22.0-zuddl.1`. `portal-flutter` pins
  one of these in its `pubspec.yaml`. Never pin a branch.
- New Amity release: `git fetch upstream`, merge `upstream/main` into `main`, fix conflicts, tag.
- `git diff 4.22.0..main` (the current Amity base) shows every Zuddl change.

## Rules

- Keep Zuddl changes small and few, so upstream merges stay easy. Prefer `assets/config/config.json`
  over code changes.
- Mark each changed spot with a `[ZUDDL]` comment, one or two lines, saying why.
- List every patch in [ZUDDL_CHANGES.md](ZUDDL_CHANGES.md) in the same commit.
- Log no PII. Keep SDK logs off.
- `flutter analyze` must show 0 errors. Upstream has many warnings and infos; don't add new ones.
- Use Flutter from `~/development/flutter`.
