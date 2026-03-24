# PR: Fix Batch/VBS code identified as code/html

**Issue:** [#337 - Batch/VBS code identified as code/html](https://github.com/CybercentreCanada/assemblyline/issues/337)

## Problem

Files containing batch/VBS scripts are being misidentified as `code/html` when they use a polyglot pattern that starts with `<!--`. This pattern is:
- Valid HTML comment (`<!--`)
- Valid batch label or comment (`:` or `::`)

Example file from the issue (WA.cmd):
```
<!-- : Begin batch script
@setlocal DisableDelayedExpansion
@set uivr=v2
@echo off
:: ### Configuration Options ###
...
```

## Root Cause Analysis

1. The polyglot file starts with `<!--` which triggers HTML yara rules `code_html_2`
2. HTML yara rules have `score = 10`
3. Batch yara rules have `score = 2`
4. YARA matches are sorted by score (highest first) in `identify.py:321`
5. HTML wins because its score is higher

## Solution

Added a new YARA rule `code_batch_html_polyglot` with `score = 15` (higher than HTML's 10) to detect polyglot patterns.

The rule uses a broad pattern `/^<!--\s*:?/` to match:
- `<!-- :` - standard polyglot (space + colon)
- `<!--:` - no space variant
- `<!-- ::` - batch comment style

**Files modified:**
- `assemblyline/common/custom.yara` - Added YARA rule
- `test/id_file_base/batch.cmd` - Normal batch test file
- `test/id_file_base/batch_polyglot.cmd` - Polyglot test file (`<!-- :` pattern)
- `test/id_file_base/batch_polyglot_doublecolon.cmd` - Polyglot variant (`<!-- ::` pattern)
- `test/id_file_base/id_file_base.json` - Added expected types

## Testing

```bash
python -m pytest test/test_identify.py::test_id_file_base -v
```

## Notes

- Score of 15 ensures it takes precedence over HTML rules (score 10)
- Requires batch command patterns to prevent false positives on actual HTML files
- The broad regex pattern `/^<!--\s*:?/` covers all common polyglot variations
