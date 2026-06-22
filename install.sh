#!/bin/bash

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES" ]; then
    echo "ERROR: ~/dotfiles does not exist"
    exit 1
fi

cd "$DOTFILES" || exit 1

echo "Starting dotfiles installation..."
echo "----------------------------------"

find . -type f -print0 | while IFS= read -r -d '' file; do

    path="${file#./}"
    target="$HOME/$path"
    target_dir="$(dirname "$target")"

    # Ignore unwanted files
    case "$path" in
        .git/* | .gitignore | README.md | LICENSE | *.bak | *.bak.*)
            continue
            ;;
    esac

    mkdir -p "$target_dir"

    # Skip if source and target are identical (extra safety)
    if [ -e "$target" ] && cmp -s "$file" "$target" 2>/dev/null; then
        echo "SKIP: $path (no changes)"
        continue
    fi

    # Backup existing file before overwrite
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup="$target.bak"

        cp -a "$target" "$backup" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "BACKUP: $path -> ${backup}"
        else
            echo "WARN: backup failed for $path"
            continue
        fi
    fi

    # Install file
    if cp -a "$file" "$target" 2>/dev/null; then
        echo "UPDATED: $path"
    else
        echo "ERROR: failed to copy $path"
    fi

done

echo "----------------------------------"
echo "Done."
