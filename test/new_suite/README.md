# New Test Suite

This folder contains additive tests only. No production files were changed to
support these tests.

Suggested commands:

```bash
flutter test test/new_suite
.venv/bin/python -m unittest discover -s tools/ml/tests -p 'test_*.py'
```

Coverage focus:

- SMS and email analyzer behavior
- ML inference and generated model contracts
- local leaderboard / XP / streak activity logic
- backend migration and endpoint contract checks
- ML dataset and training pipeline contract checks
