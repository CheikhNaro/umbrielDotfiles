#!/usr/bin/env bash
# output-workspaces.sh — range les fenêtres orphelines d'un écran débranché
#
# Quand un output disparaît, Umbriel recopie chacun de ses workspaces *peuplés*
# en workspace temporaire sur un écran restant, et un workspace nommé y garde son
# nom : « 6 », « 7 »… C'est ce qui les fait pousser sur l'écran principal. Aucun
# réglage ne désactive ça, mais un temporaire vidé est supprimé de lui-même. Ce
# script se contente donc de les vider, vers l'écran qui les héberge.


set -uo pipefail

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/umbriel/output-workspaces-prev.json"

# Ligne par fenêtre à déplacer : "id_fenêtre  destination  écran_qui_héberge"
plan() {   # $1 = outputs, $2 = workspaces, $3 = fenêtres, $4 = instantané de référence
    jq -rn --argjson co "$1" --argjson cw "$2" --argjson cn "$3" --argjson prev "$4" '
        ([ $co[] | .name ]) as $present
        | ([ $co[] | select(.enabled) | .name ]) as $now
        | [ $prev.outputs[] | select( .name as $n | ($present | index($n)) | not ) | .name ] as $gone
        | ( [ $prev.workspaces[] | select( .output as $o | $gone | index($o) ) ]
            | group_by(.output) | map(sort_by(.index)) ) as $lost
        | [ $lost[] | .[].name ] as $lost_names
        | [ $prev.workspaces[] | "\(.output)/\(.id)" ] as $known
        | [ $cw[]
            | select( .output as $o | $now | index($o) )
            | select( ( "\(.output)/\(.id)" ) as $k | ($known | index($k)) | not )
            | . as $t
            | ( [ $prev.workspaces[] | select(.output == $t.output) ] | sort_by(.index) ) as $home
            | select($home | length > 0)
            | ( $lost_names | index($t.name) ) // ( $t.index - ($home | length) - 1 ) as $rank
            | select($rank >= 0)
            | $home[$rank % ($home | length)].name as $dst
            | { id: $t.id, dst: $dst, out: $t.output }
          ] as $moves
        | [ $moves[] as $m | $cn[] | select(.workspace == $m.id)
            | "\(.id)\t\($m.dst)\t\($m.out)" ]
        | .[]?
    '
}

snapshot() {
    printf '{"outputs":%s,"workspaces":%s,"windows":%s}' \
        "$(umbriel outputs --json 2>/dev/null || echo '[]')" \
        "$(umbriel workspaces --json 2>/dev/null || echo '[]')" \
        "$(umbriel windows --json 2>/dev/null || echo '[]')"
}

run() {   # $1 = "plan" pour ne rien déplacer
    local cur prev mode="${1:-run}"
    cur="$(snapshot)"
    prev="$(cat "$STATE_FILE" 2>/dev/null || true)"
    if [[ "$mode" != "plan" ]]; then
        mkdir -p "$(dirname "$STATE_FILE")"
        printf '%s' "$cur" > "$STATE_FILE"
    fi

    [[ -n "$prev" ]] || return 0
    local wid dst out
    while IFS=$'\t' read -r wid dst out; do
        [[ -n "$wid" && -n "$dst" ]] || continue
        if [[ "$mode" == "plan" ]]; then
            printf '%s\t%s\t%s\n' "$wid" "$dst" "$out"
            continue
        fi
        umbriel msg window-focus "$wid" 2>/dev/null || true
        umbriel msg window-move-to-workspace-silent --name "$dst" --output "$out" 2>/dev/null || true
    done < <(plan \
        "$(jq -c '.outputs' <<< "$cur")" \
        "$(jq -c '.workspaces' <<< "$cur")" \
        "$(jq -c '.windows' <<< "$cur")" \
        "$prev")
}

case "${1:-run}" in
    daemon)
        # Deux instances se disputeraient l'instantané de référence.
        exec 9>"${STATE_FILE}.lock"
        flock -n 9 || exit 0
        # `subscribe outputs` renvoie un instantané à la connexion, puis à chaque
        # changement. Le premier ne trouve aucune référence : il ne fait que l'écrire.
        umbriel subscribe outputs 2>/dev/null | while IFS= read -r _; do
            sleep 0.6   # laisse l'évacuation d'Umbriel se terminer avant de lire
            run run
        done
        ;;
    plan) run plan ;;
    *)    run run ;;
esac
