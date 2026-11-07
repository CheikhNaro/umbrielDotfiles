#!/bin/bash
# screenshot.sh — Capture de fenêtre uniquement pour Umbriel (Noctalia natif)
# Invoquée par Alt+Print : cliquer une fenêtre du workspace actif,
# capture via grim, puis annotation Noctalia.

ACCENT="#67aae4"

_window_geom() {
    local active_ws geom
    active_ws=$(umbriel workspaces --json 2>/dev/null | jq -c '[.[] | select(.active==true) | .id]')
    [ -z "$active_ws" ] || [ "$active_ws" = "null" ] && active_ws="[]"

    geom=$(umbriel windows --json 2>/dev/null | \
        jq -r --argjson aws "$active_ws" '
            .[]
            | select(.scratchpad == "" and (.workspace as $w | $aws | index($w)) != null and .app_id != "at.yrlf.wl_mirror")
            | "\(.x),\(.y) \(.w)x\(.h)"
        ' | \
        slurp -b '#00000000' -B '#00000000' -c "${ACCENT}AA" -w 2 -s '#ffffff30')
    [ -z "$geom" ] && exit 0
    echo "$geom"
}

geom=$(_window_geom)
[ -z "$geom" ] && exit 0

TMPFILE=$(mktemp /tmp/screenshot-window-XXXXXX.png)
# Le layer « selection » de slurp disparaît avec le fondu des layers
# (animations.toml, duration_ms = 220). Sans attente, grim capture le
# voile gris : mesuré, mean 0.507 à +50 ms, 0.383 (normal) à +150 ms.
sleep 0.3
grim -g "$geom" "$TMPFILE" && noctalia msg annotate "$TMPFILE"
