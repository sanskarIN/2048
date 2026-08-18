# Phase 30 Documentation Finalizer Trigger

Temporary trigger for the one-shot Phase 30 documentation indexing and cleanup workflow. The workflow removes this file and itself after completing the indexed documentation update.

Retriggered after the finalizer workflow was installed on `main` to ensure the path-filtered push is observed from the active workflow definition.
