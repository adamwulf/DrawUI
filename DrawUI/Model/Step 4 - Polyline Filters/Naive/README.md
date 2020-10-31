#  Naive Filters

These naive filters complete ignore their input `deltas`, and instead complete refilter the entire `lines` for any added or updated lines.

This leaves an optimization opportunity to only filter the portion of the line that has changed, however these filters will filter the entire line regardless
of what has changed.

