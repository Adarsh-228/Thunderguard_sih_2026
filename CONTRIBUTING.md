# 🤝 Contributing to ThunderGuard

Thank you for your interest in contributing to **ThunderGuard** — an AI/ML-powered thunderstorm and lightning nowcasting platform built for Smart India Hackathon 2026.

This document outlines the process for contributing to this project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

---

## 🤝 Code of Conduct

By contributing, you agree to:
- Be respectful and inclusive in all interactions
- Provide constructive feedback
- Focus on what is best for the project and the team
- Avoid any discriminatory or harassing behaviour

---

## 🛠️ How to Contribute

### 1. Fork the Repository

```bash
# Fork via GitHub UI, then clone your fork
git clone https://github.com/<your-username>/Thunderguard_sih_2026.git
cd Thunderguard_sih_2026
```

### 2. Create a Branch

Always branch off from `main`. Use a descriptive branch name:

```bash
# Feature
git checkout -b feat/lightning-heatmap-animation

# Bug fix
git checkout -b fix/alert-overflow-error

# Documentation
git checkout -b docs/update-api-section

# Refactor
git checkout -b refactor/risk-map-screen
```

### 3. Make Your Changes

Follow the [Coding Standards](#coding-standards) below.

### 4. Test Your Changes

```bash
# Static analysis — must pass with 0 errors
flutter analyze

# Run unit tests
flutter test

# Build APK to verify no build-time errors
flutter build apk --debug
```

### 5. Commit and Push

```bash
git add .
git commit -m "feat: add district-level risk heatmap animation"
git push origin feat/lightning-heatmap-animation
```

### 6. Open a Pull Request

Go to GitHub and open a PR against the `main` branch. Fill in the PR template.

---

## 💻 Development Setup

### Requirements

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.12.x |
| Dart SDK | ≥ 3.12.x |
| Android Studio | Hedgehog or later |
| VS Code | Latest + Flutter extension |
| Android device/emulator | API 21+ |

### First-time Setup

```bash
# Install Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor

# Run on device
flutter run

# Run on Windows desktop
flutter run -d windows
```

---

## 📁 Project Structure

```
lib/thunderguard/
├── core/           # Colors, theme tokens
├── widgets/        # Reusable shared widgets
├── screens/        # Full screen views
└── shell/          # Navigation wrapper
```

**Where to add things:**
- New shared widgets → `lib/thunderguard/widgets/tg_widgets.dart`
- New screens → `lib/thunderguard/screens/<name>_screen.dart`
- Color/theme changes → `lib/thunderguard/core/`
- New entry in nav → `lib/thunderguard/shell/tg_shell.dart`

---

## ✅ Coding Standards

### Dart / Flutter

- **Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)** style guidelines
- Use `const` constructors wherever possible
- Prefer `TextOverflow.ellipsis` on all `Text` widgets inside `Row`/`Column`
- Wrap all `Row` children with text in `Expanded` or `Flexible`
- Never use hardcoded colours — always use `TGColors.*` tokens
- Avoid magic numbers — use named constants or spacing variables

```dart
// ✅ Good
Text(district, overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: TGColors.textPrimary, fontSize: 13))

// ❌ Bad
Text(district, style: TextStyle(color: Color(0xFFF0F2F8), fontSize: 13))
```

### Widget Guidelines

- Keep widgets small and focused — split large `build()` methods into private `_Xxx` widgets
- Prefer `StatelessWidget` unless state is truly needed
- Always `dispose()` controllers in `State.dispose()`
- Use `withValues(alpha: x)` instead of deprecated `withOpacity(x)`

```dart
// ✅ Good
color: TGColors.lightning.withValues(alpha: 0.15)

// ❌ Deprecated
color: TGColors.lightning.withOpacity(0.15)
```

### File Naming

| Type | Convention | Example |
|---|---|---|
| Screens | `snake_case_screen.dart` | `risk_map_screen.dart` |
| Widgets | `snake_case.dart` | `tg_widgets.dart` |
| Classes | `PascalCase` | `RiskMapScreen` |
| Private helpers | `_PascalCase` | `_DistrictRow` |
| Functions | `camelCase` | `buildAlertCard()` |

---

## 📝 Commit Guidelines

We follow **[Conventional Commits](https://www.conventionalcommits.org/)**.

### Format

```
<type>(<scope>): <short description>

[optional body]
[optional footer]
```

### Types

| Type | When to use |
|---|---|
| `feat` | New feature or screen |
| `fix` | Bug fix |
| `ui` | UI/visual-only change |
| `refactor` | Code restructure without behaviour change |
| `docs` | README, CONTRIBUTING, comments |
| `test` | Adding or fixing tests |
| `chore` | Build scripts, dependencies, config |
| `perf` | Performance improvement |

### Examples

```bash
git commit -m "feat(analytics): add CAPE chart with threshold lines"
git commit -m "fix(alerts): fix text overflow in district name row"
git commit -m "ui(home): reduce stat tile padding for mobile screens"
git commit -m "docs: update README with AI architecture diagram"
git commit -m "chore: upgrade fl_chart to 1.2.0"
```

---

## 🔀 Pull Request Process

1. **Ensure CI passes** — `flutter analyze` with 0 errors, `flutter test` green
2. **Update documentation** — If you add a screen or widget, update `README.md`
3. **Keep PRs focused** — One feature / fix per PR, not a bundle of unrelated changes
4. **Write a clear PR description** including:
   - What changed and why
   - Screenshots or screen recordings for UI changes
   - Any breaking changes
5. **Request review** from at least one team member
6. **Squash commits** before merging if the branch has many WIP commits

### PR Title Format

```
feat(screen): add lightning risk heatmap animation
fix(alerts): resolve text overflow on small screens
```

---

## 🐛 Reporting Bugs

Open a GitHub Issue with the following:

```markdown
**Describe the bug**
A clear description of the issue.

**Steps to Reproduce**
1. Go to '...'
2. Tap on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment**
- Flutter version: x.x.x
- Device/OS: Android 13 / Pixel 6
- App version: v1.0.0-beta
```

---

## 💡 Feature Requests

Open a GitHub Issue with label `enhancement`:

```markdown
**Feature Description**
Brief description of the feature.

**Motivation**
Why is this needed? What problem does it solve?

**Proposed Implementation**
If you have ideas on how to implement it.

**Alternatives Considered**
Any other approaches you considered.
```

---

## 📬 Contact

For direct questions, reach out to the team:

- **Team**: Debuggers_26
- **Problem Statement**: SIH26072
- **GitHub**: [@Adarsh-228](https://github.com/Adarsh-228)

---

*Happy contributing! Let's build something that saves lives. ⚡*
