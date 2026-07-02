# vex_git

> Mobile-first Git client for GitHub, built with Flutter.

vex_git is a phone-shaped port of the GitHub Desktop experience. It targets
individual developers who want a clean, focused Git workflow on Android and iOS
without paying for GitHub Mobile or wrestling with a terminal app.

## Highlights

- GitHub Device-Flow authentication (sign in with a one-time code, no PAT juggling)
- Clone from URL, scan QR, or add an existing local repo
- Working copy at a glance: staged / unstaged / untracked counts, ahead/behind
- Stage, unstage, discard, and commit with author/email and GPG/SSH signing toggles
- Branch, stash, fetch / pull / push, conflict resolution entry point
- Pull request list, detail, and create flow backed by the GitHub REST API
- History graph with diff viewer (line + word highlighting, swipe-to-dismiss)
- Local-first configuration stored in `.vex_git.config` inside the project root;
  cloned repos live in `.vex_git_store` next to it
- Secrets (tokens, signing keys) go through `flutter_secure_storage` (Keychain /
  Keystore / Windows Credential Manager)

## Architecture

Clean Architecture, three layers, unidirectional dependencies:

```
lib/
  domain/         # pure Dart: entities, repository interfaces, use cases
  infrastructure/ # git CLI bridge, GitHub REST, secure storage, config repo
  presentation/   # Riverpod providers, screens, widgets
  app/            # theme, router, dependency wiring
  core/           # errors, paths, constants, utilities
  l10n/           # generated AppLocalizations (en, zh)
```

- State management: Riverpod 2 (50+ providers, no `setState` for business state)
- Error model: sealed `Result<T>` / `Failure` so the UI never sees a raw exception
- Git I/O: `Process` against the system `git` binary (no libgit2 FFI, v1 keeps
  things boring and debuggable)
- Networking: `package:http` against the GitHub REST API
- Routing: `go_router` with deep links

## Getting Started

### Prerequisites

- Flutter 3.44+ (Dart 3.12+)
- `git` available on `PATH`
- For Android: Android Studio / cmdline-tools, an Android SDK image
- For iOS: macOS with Xcode 15+

### Run

```bash
flutter pub get
flutter gen-l10n     # only needed if you edit lib/l10n/*.arb
flutter run
```

### Test & Analyze

```bash
flutter analyze      # zero warnings expected
flutter test         # 11 unit / smoke tests
```

### Build

```bash
flutter build apk --release
flutter build appbundle
flutter build ios --release      # macOS only
```

## Data Layout

All user data lives inside the project root so a single folder is portable:

| Path | Purpose |
| --- | --- |
| `.vex_git.config` | App config (accounts, repos, preferences) as JSON |
| `.vex_git_store/` | Bare + working copies of cloned repositories |

Both paths are configurable in Settings -> Storage. The defaults keep your
secrets and code reviewable in version control if you so choose; in practice
add `.vex_git.config` and `.vex_git_store/` to your global git ignore.

Tokens and signing material are **never** written to `.vex_git.config`. They
go through the OS secure store, keyed by account id.

## Project Status

This is a single-developer, single-repo build. Scope is "everything GitHub
Desktop does, on a phone", minus the parts that only make sense on a desktop
(window management, editor integration, GitHub Actions runners).

## License

Private project. All rights reserved.