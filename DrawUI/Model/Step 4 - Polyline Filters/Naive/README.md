#  Naive Filters

These naive filters complete ignore their input `deltas`, and instead refilter the entire `lines` for any added or updated lines.

This leaves an optimization opportunity to only filter the portion of the line that has changed.
