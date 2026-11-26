# amity-uikit-flutter (Zuddl fork)

Zuddl's fork of Amity's Social+ Flutter UIKit (`AmityCo/Amity-Social-UIKit-Flutter-Opensource`).
Used only by `portal-flutter` for the event Feed. Design: Linear "Tech Spec: Portal Flutter Feed".

## ⛔ This repo is public

Anyone can read every file, commit, tag and commit message here. `portal-flutter` CI clones it
without credentials, so it stays public.

- Never commit anything secret or private to Zuddl: API keys, tokens, Amity/Social+ keys, auth
  tokens, signing files, Firebase configs, `.env` files, internal or staging URLs, customer or event
  names, attendee data, emails or screenshots of real events.
- Keys and config come from `portal-flutter` at runtime, never from this repo.
- No links to private Zuddl repos, Linear tickets, Slack or internal docs in code, comments,
  `ZUDDL_CHANGES.md` or commit messages. Say what the change does instead.
- Test data is made up (`user-1`, `community-1`), never copied from a real event.
- Before each push, check the diff for any of the above. If something slipped in, don't push. A
  pushed secret is leaked even after a revert: rotate it.

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
