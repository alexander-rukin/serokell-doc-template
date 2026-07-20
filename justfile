# Serokell document template
#
#   just build example-proposal   -> out/example-proposal.pdf
#   just watch example-proposal   -> rebuild on every save
#   just all                      -> build every document in content/
#   just list                     -> show available documents

_default:
    @just --list --unsorted

# Build one document from content/ into out/
build doc:
    @./build.sh {{doc}}

# Rebuild a document continuously as you edit it
watch doc:
    @./build.sh {{doc}} --watch

# Build every .md in content/
all:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in content/*.md; do
      [ -e "$f" ] || continue
      ./build.sh "$(basename "${f%.md}")"
    done

# List the documents available to build
list:
    @ls content/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' || echo "no documents in content/"

# Remove build output
clean:
    @rm -rf out && echo "removed out/"
