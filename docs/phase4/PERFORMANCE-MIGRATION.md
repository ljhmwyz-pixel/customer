# Local Performance and Migration Verification

Date: 2026-08-06

## Migration Evidence

Focused migration suite passed 33 tests across fresh v8 schema creation, historical v1-to-v8 upgrades, v6-to-v7 attachment migration, and v7-to-v8 sample-data migration. The suite checks row preservation, schema version, indexes, attachment ownership, cascades, and foreign-key behavior.

## Performance Evidence

The performance fixture now contains 500 customers, 1500 projects, 5000 follow-ups, and 400 plans. Core in-memory queries and the file-backed urgency query are required to remain below 200 ms.

Observed current-run medians:

- In-memory urgency list: 3.631 ms.
- In-memory advanced combined filter: 0.674 ms.
- File-backed urgency list: 3.416 ms.

## Open Boundary

Cold-start timing and target-device performance still require OnePlus 13 / ColorOS 15 measurement.
