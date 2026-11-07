#!/usr/bin/env bash
QML="$HOME/.config/quickshell/quickPaper/shell.qml"
if pid=$(pgrep -f "[q]s -p $QML"); then kill $pid; exit 0; fi
RUN="${XDG_RUNTIME_DIR:-/tmp}"
MINI="$HOME/.cache/quickpaper/miniatures"; mkdir -p "$MINI"

# ── liste + miniatures 720 px en cache (seules les nouvelles/modifiées sont générées, en parallèle) ──
LISTE="$RUN/quickpaper-liste"; : > "$LISTE.tmp"; afaire=()
shopt -s nullglob nocaseglob
for f in "$HOME"/Images/Wallpaper/*.{jpg,jpeg,png,webp,avif}; do
  b=$(basename "${f%.*}"); m="$MINI/$b.jpg"
  [[ -s "$m" && "$m" -nt "$f" ]] || afaire+=("$f")
  nom=${b#[0-9][0-9]-}; nom=${nom//[-_]/ }
  printf '%s\t%s\t%s\n' "$nom" "$f" "$m" >> "$LISTE.tmp"
done
sort -f -t$'\t' -k2,2 "$LISTE.tmp" > "$LISTE"; rm -f "$LISTE.tmp"
if (( ${#afaire[@]} )); then
  printf '%s\0' "${afaire[@]}" | xargs -0 -P"$(nproc)" -I{} bash -c '
    f="$1"; b=$(basename "${f%.*}")
    magick "$f[0]" -thumbnail 720x405^ -gravity center -extent 720x405 -quality 85 "$2/$b.jpg"' _ {} "$MINI"
fi

# ── écran focus (pour afficher le carrousel) + fond actuellement appliqué ──
ECRAN=$(umbriel workspaces --json 2>/dev/null | jq -r '.[] | select(.focused) | .output' 2>/dev/null | head -1)
cur=$(noctalia msg wallpaper-get 2>/dev/null | head -1)
export QUICKPAPER_CURRENT="$cur" QUICKPAPER_ECRAN="$ECRAN" QUICKPAPER_LISTE="$LISTE"
export QUICKPAPER_ACCENT="$(awk '/^active_border_color/{print $2}' ~/.config/kitty/themes/noctalia.conf 2>/dev/null)"
qs -p "$QML" >/dev/null 2>&1     #bloquant :qs quitte quand Qt.quit() est appelé
# Le QML applique lui-même chaque fond validé (noctalia msg wallpaper-set +
# sync-sddm-wallpaper en direct) et reste ouvert jusqu'à Échap.
