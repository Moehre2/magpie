#!/bin/bash

# Setup temporary directory
if [ -z $TMP ]; then
    TMP=/tmp
fi
tmpdir="$(mktemp -d "$TMP/XXXXXX")"

# Copy files
stolenfiles=""
while [ "$1" != "" ]; do
    echo "Copy $1"
    cp "$1" "$tmpdir/"
    stolenfiles="$stolenfiles $(echo $1 | rev | cut -d '/' -f1 | rev)"
    shift
done

# Setup shell
echo "Setup shell"
echo 'if [ -f "$HOME/.bashrc" ]; then' > "$tmpdir/.bashrc"
echo '    source "$HOME/.bashrc"' >> "$tmpdir/.bashrc"
echo 'fi' >> "$tmpdir/.bashrc"
echo 'PS1="(magpie) $PS1"' >> "$tmpdir/.bashrc"
echo "cd $tmpdir" >> "$tmpdir/.bashrc"

# Start shell
bash --rcfile "$tmpdir/.bashrc"

# Check exit code
if [ "$?" != "0" ]; then
    echo "Kept files in: $tmpdir"
    exit 1
fi

# Copy files back
for f in $stolenfiles; do
    echo "Copy $f"
    cp "$tmpdir/$f" .
done

# Delete temporary directory
rm -rf "$tmpdir"