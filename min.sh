#!/usr/bin/env bash
set -euo pipefail

# 1) Your source + destination files
IN="a5-tester.html"
OUT="carpmmin.html"

# 2) Temp files
TMP_CSS=$(mktemp)   # will hold your raw CSS block
TMP_REPL=$(mktemp)  # will hold the HTML with a placeholder

# 3) Extract everything between your markers (including the markers)
awk '/<!-- CSS-NO-MINIFY-START -->/,/<!-- CSS-NO-MINIFY-END -->/' \
  "$IN" > "$TMP_CSS"

# 4) Replace that entire chunk with a zero-length <style> placeholder
#    (we give it an ID so it’s easy to find again)
sed '/<!-- CSS-NO-MINIFY-START -->/,/<!-- CSS-NO-MINIFY-END -->/c\
<style id="protected"></style>' \
  "$IN" > "$TMP_REPL"

# 5) Run html-minifier-terser *with* --minify-css (so every other <style> still gets shrunk)
html-minifier-terser \
  --collapse-whitespace \
  --remove-comments \
  --remove-attribute-quotes \
  --collapse-boolean-attributes \
  --remove-empty-attributes \
  --minify-js \
  --minify-css \
  -o "$TMP_REPL" \
  "$TMP_REPL"

# 6) Find the placeholder <style id="protected"></style> in the minified HTML,
#    delete that line, and replace it with your original block
sed '/<style id="protected"><\/style>/{
  r '"$TMP_CSS"'
  d
}' "$TMP_REPL" > "$OUT"

# 7) Cleanup
rm "$TMP_CSS" "$TMP_REPL"

echo "✅  Done. Check your un-minified section in $OUT"

