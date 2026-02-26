#!/bin/bash
set -e

repo_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_path"

old_base=$(git rev-list --reverse dev | head -n 1)

git fetch sunnypilot dev
new_base=$(git rev-parse sunnypilot/dev)

if [ "$old_base" = "$new_base" ]; then
    echo "up to date"
    git push ovgolovin dev --force-with-lease
    exit 0
fi

source_commits=$(git rev-list --reverse dev ^"$old_base")
dest_commit="$new_base"

for source_commit in $source_commits; do
    base_commit=$(git rev-parse "$source_commit^1")
    
    merged_tree=$(git merge-tree --write-tree --merge-base "$base_commit" "$dest_commit" "$source_commit") || {
        echo "conflict detected at $source_commit"
        exit 1
    }
    
    eval "$(git log -1 --format='export GIT_AUTHOR_NAME="%an" GIT_AUTHOR_EMAIL="%ae" GIT_AUTHOR_DATE="%ad"' "$source_commit")"
    
    dest_commit=$(git commit-tree "$merged_tree" -p "$dest_commit" -m "$(git log -1 --format=%B "$source_commit")")
done

git update-ref refs/heads/dev "$dest_commit"
git push ovgolovin dev --force-with-lease
