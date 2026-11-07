#!/usr/bin/env bash
# toggle-monitor.sh — bascule d'écrans sous Umbriel Modes : étendu ↔ miroir ↔ interne seul
#
# Tout passe par les commandes natives d'Umbriel :
#   umbriel outputs --json              → détection, modes, positions
#   umbriel msg output-enable|disable   → état temporaire (aucune écriture de config)
#   wlr-randr                           → mode/position live de la sortie isolée
#   wl-mirror                           → aucun miroir natif dans Umbriel/Noctalia
#
# En mode miroir la sortie externe est déplacée hors du bureau ([10000, 0])
# En mode interne seul, les fenêtres de la sortie externe sont mémorisées puis remises sur leur écran/espace d'origine au retour en mode étendu.

set -euo pipefail

STATE_DIR="${HOME}/.config/umbriel/state"
MODE_FILE="${STATE_DIR}/monitor-mode"
DISPLACED_FILE="${STATE_DIR}/displaced-windows"

INTERNAL="eDP-1"
MIRROR_X=10000
MIRROR_STEP=5000

mkdir -p "${STATE_DIR}"

# ── mode demandé ──────────────────────────────────────────────────────────
current="$(cat "${MODE_FILE}" 2>/dev/null || echo extended)"
case "${1:-}" in
    detect)   mode="${current}" ;;
    extended|mirror|single) mode="${1}" ;;
    "") case "${current}" in
            extended) mode=mirror ;;
            mirror)   mode=single ;;
            *)        mode=extended ;;
        esac ;;
    *) echo "usage: $0 [detect|extended|mirror|single]" >&2; exit 2 ;;
esac
printf '%s\n' "${mode}" > "${MODE_FILE}"

outputs() { umbriel outputs --json 2>/dev/null || echo '[]'; }

JSON="$(outputs)"

# ── sorties externes (tout sauf l'écran interne) ──────────────────────────
mapfile -t EXTERNALS < <(jq -r --arg i "${INTERNAL}" '.[] | select(.name != $i) | .name' <<<"${JSON}")

# ── modes : mode_str <sortie> [largeur hauteur] → "1920x1080@60Hz" (le meilleur mode, éventuellement restreint à une résolution).
mode_str() {
    local name="$1" w="${2:-0}" h="${3:-0}"
    jq -r --arg n "${name}" --argjson w "${w}" --argjson h "${h}" '
        .[] | select(.name == $n) | .modes
        | (if $w > 0 then map(select(.width == $w and .height == $h)) else . end)
        | max_by([.width * .height, .refresh_mhz])
        | select(. != null)
        | "\(.width)x\(.height)@\((.refresh_mhz / 1000) | round)Hz"
    ' <<<"${JSON}"
}

mode_width() {
    local w="${1%%x*}"
    [[ "${w}" =~ ^[0-9]+$ ]] && echo "${w}" || echo 1920
}

internal_mode="$(jq -r --arg n "${INTERNAL}" '
    .[] | select(.name == $n) | .modes[] | select(.current)
    | "\(.width)x\(.height)@\((.refresh_mhz / 1000) | round)Hz"' <<<"${JSON}" | head -1)"
: "${internal_mode:=1920x1080@60Hz}"
internal_w="${internal_mode%%x*}"
internal_h="${internal_mode#*x}"; internal_h="${internal_h%%@*}"

# ── helpers ──────────────────────────────────────────────────────────────
stop_mirror() { pkill -x wl-mirror 2>/dev/null || true; }

focus_output() {   # donne le focus clavier à une sortie (placement du miroir)
    local target="$1" i
    for i in 1 2 3 4; do
        if [[ "$(outputs | jq -r --arg n "${target}" '.[] | select(.name == $n) | .focused')" == true ]]; then
            return 0
        fi
        umbriel msg output-focus-next
        sleep 0.15
    done
}

active_ws() {
    umbriel workspaces --json | jq -r --arg o "${INTERNAL}" '.[] | select(.output == $o and .active) | .name'
}

# Umbriel 0.1.0 ne restaure pas les fenêtres d'une sortie réactivée : on mémorise leur sortie/espace d'origine avant output-disable, puis on les remet en place au retour en mode étendu (window-focus + move silencieux).
save_external_windows() {
    local tmp="${DISPLACED_FILE}.tmp"
    umbriel windows --json | jq -r --slurpfile ws <(umbriel workspaces --json) --arg i "${INTERNAL}" '
        .[] | . as $w
        | ($ws[0][] | select(.id == $w.workspace)) as $s
        | select($s.output != $i)
        | "\($w.id)\t\($s.output)\t\($s.name)"
    ' > "${tmp}"
    # Ne pas écraser une sauvegarde existante si l'écran externe est déjà vide.
    if [[ -s "${tmp}" ]]; then mv -f "${tmp}" "${DISPLACED_FILE}"; else rm -f "${tmp}"; fi
}

restore_external_windows() {
    local id out ws current
    [[ -s "${DISPLACED_FILE}" ]] || return 0
    current="$(umbriel windows --json)"
    while IFS=$'\t' read -r id out ws; do
        [[ -n "${id}" ]] || continue
        jq -e --arg i "${id}" 'any(.[]; .id == $i)' <<<"${current}" >/dev/null || continue
        umbriel msg window-focus "${id}" || continue
        umbriel msg window-move-to-workspace-silent --name "${ws}" --output "${out}" || true
    done < "${DISPLACED_FILE}"
    rm -f "${DISPLACED_FILE}"
}

# ── modes ────────────────────────────────────────────────────────────────
apply_extended() {
    local ext best x saved_ws
    saved_ws="$(active_ws)"
    stop_mirror
    sleep 0.3
    x="$(mode_width "${internal_mode}")"
    for ext in "${EXTERNALS[@]}"; do
        umbriel msg output-enable "${ext}"
        best="$(mode_str "${ext}")"
        if [[ -n "${best}" ]]; then
            wlr-randr --output "${ext}" --mode "${best}" --pos "${x},0"
        else
            wlr-randr --output "${ext}" --pos "${x},0"
        fi
        x=$((x + $(mode_width "${best}")))
    done
    restore_external_windows
    [[ -z "${saved_ws}" ]] || umbriel msg workspace-switch "${saved_ws}" --output "${INTERNAL}"
}

apply_mirror() {
    local ext best x i=0 saved_ws
    saved_ws="$(active_ws)"
    stop_mirror
    sleep 0.3

    for ext in "${EXTERNALS[@]}"; do
        x=$((MIRROR_X + MIRROR_STEP * i)); i=$((i + 1))
        best="$(mode_str "${ext}" "${internal_w}" "${internal_h}")"
        umbriel msg output-enable "${ext}"
        if [[ -n "${best}" ]]; then
            wlr-randr --output "${ext}" --mode "${best}" --pos "${x},0"
        else
            wlr-randr --output "${ext}" --pos "${x},0"
        fi
        focus_output "${ext}"
        umbriel msg spawn wl-mirror --show-cursor --scaling fit --fullscreen-output "${ext}" "${INTERNAL}"
    done

    # Le focus clavier revient sur l'écran interne (delay : la fenêtre miroir vient de se mapper, son placement peut encore déplacer le focus).
    sleep 0.3
    [[ -z "${saved_ws}" ]] || umbriel msg workspace-switch "${saved_ws}" --output "${INTERNAL}"
}

apply_single() {
    local ext
    stop_mirror
    sleep 0.3
    save_external_windows
    for ext in "${EXTERNALS[@]}"; do
        umbriel msg output-disable "${ext}"
    done
}

count="${#EXTERNALS[@]}"
[[ "${count}" -gt 0 ]] || mode=single

case "${mode}" in
    extended) apply_extended; label="Étendu" ;;
    mirror)   apply_mirror;   label="Miroir" ;;
    single)   apply_single;   label="Interne seul" ;;
esac

notify-send -u low "Écrans" "Mode: ${label} (${count} externe(s))"