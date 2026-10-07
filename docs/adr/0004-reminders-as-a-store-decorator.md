# 0004: Keep reminders in sync with a store decorator

- Status: Accepted
- Date: 2026-10-05

## Context

Due-date reminders must be scheduled, rescheduled or cancelled whenever a task is added, edited, completed or deleted. Tasks can be written from the list screen and from an App Intent. Putting reminder calls in the view model would mean the intent has to repeat them.

## Decision

`ReminderSyncingStore` implements `TodoStore` by wrapping another store and a `ReminderScheduling`. After each successful write it applies one rule, `Reminder(for:now:)`, to decide between scheduling and cancelling. The composition root wraps `CoreDataTodoStore` with it, and everything else uses it as a plain `TodoStore`.

## Consequences

- Any write path gets reminders for free, and the rule is tested once, with mocks.
- Reminder failures never fail a save. Scheduling is best effort and failures are logged.
- UI tests and previews just leave the decorator out, which also keeps the notification permission prompt out of automated runs.
