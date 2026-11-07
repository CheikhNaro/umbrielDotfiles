#!/usr/bin/env bash
# cycle-layout.sh — fait tourner le layout du workspace actif dans le cycle
# complet des layouts natifs d'Umbriel.
#
#   cycle-layout.sh            → next: dwindle → master → scrolling → stacking → …
#   cycle-layout.sh <layout>   → force un layout précis
#
# La position dans le cycle est relue à chaque appel (workspaces --json) :
# aucun état, aucun daemon ; fonctionne aussi pour les fenêtres ouvertes après.

set -uo pipefail

CYCLE=(dwindle master scrolling stacking)

if [[ $# -ge 1 && "$1" != "--" ]]; then
    target="$1"
else
    current="$(umbriel workspaces --json 2>/dev/null | jq -r '.[] | select(.focused) | .layout')"
    idx=0
    for i in "${!CYCLE[@]}"; do
        [[ "${CYCLE[i]}" == "${current}" ]] && idx=$(( (i + 1) % ${#CYCLE[@]} )) && break
    done
    target="${CYCLE[idx]}"
fi

umbriel msg workspace-set-layout "${target}"

notify-send -a Umbriel -u low "Layout : ${target}" 2>/dev/null || true
