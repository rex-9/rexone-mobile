# Contributing to RexOne Mobile

Thank you for contributing to **RexOne Mobile**! 📱

RexOne Mobile is a Flutter application targeting Android, iOS, Linux, macOS, and Windows, engineered under **Discipline-Driven Development (DDD)**.

---

## 🏛️ Constitutional Law

All mobile development is governed by **[`LAW.md`](LAW.md)** and **[`ECOSYSTEM.md`](ECOSYSTEM.md)**.
- **Law M1 (Universal Provider Isolation)**: Media storage uses `storage_key`. Drift SQLite offline schema is canonical.
- **Law U14 (Zero Loose Code)**: Strict, deterministic Dart contracts for all services and state models.
- **Law U15 (Human-Readable Code)**: No alien syntax, dense nested ternaries, or unreadable regex hacks.

---

## 🛠️ Local Development & Pre-Commit Verification

Before opening a pull request, run the full verification pipeline:

```bash
# 1. Check for staged credentials or .env leaks
./scripts/check_secrets.sh

# 2. Dart Static Analysis
flutter analyze

# 3. Flutter Unit & Widget Tests
flutter test
```

---

## 🤖 AI-Assisted Contributions

AI pair programmers are welcome, but unvetted "AI Slop" is rejected.
- Every PR must disclose AI tools used.
- Tests and static analysis must pass 100%.
- For details, see the [RexOne AI Contribution Policy](https://github.com/rex-9/rexone-core/blob/dev/docs/AI_CONTRIBUTION_POLICY.md).
