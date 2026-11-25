#!/usr/bin/env bash
# Launches the Unreal Editor of an engine install named in unreal-versions.nix.
#
# Usage: launch-editor.sh [version] [editor args...]
#   version  a name from unreal-versions.nix, such as 5_6. Without it, the default install runs.
#   The other arguments go to the editor, such as a .uproject path.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

versions=$(nix eval --raw --file "$here/unreal-versions.nix" \
	--apply 'v: builtins.concatStringsSep " " (builtins.attrNames (removeAttrs v ["default"]))')

app=default
if [ $# -gt 0 ]; then
	if [[ " $versions " == *" $1 "* ]]; then
		app=$1
		shift
	elif [[ $1 != -* ]] && [ ! -e "$1" ]; then
		echo "launch-editor.sh: '$1' is neither a version nor a path. Versions: $versions" >&2
		exit 2
	fi
fi

# The editor resolves a relative project path against its own directory.
args=()
for a in "$@"; do
	if [[ $a == *.uproject ]] && [ -f "$a" ]; then
		a=$(realpath "$a")
	fi
	args+=("$a")
done

exec nix run "$here#$app" -- "${args[@]}"
