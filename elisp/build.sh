#!/bin/bash

DOCSET_NAME="Emacs Lisp"
SOURCE_URL=http://www.gnu.org/software/emacs/manual/elisp.html_node.tar.gz
SOURCE_MD5=9db39d40ada794b3ed8806a4fb9cf10c

DOCSETUTIL=/Applications/Xcode.app/Contents/Developer/usr/bin/docsetutil

function make_structure {
    local DOCSET="$DOCSET_NAME.docset"
    mkdir -p "$DOCSET/Contents/Resources/Documents" &&
    cp "src/Info.plist" "$DOCSET/Contents" &&
    cp "src/Nodes.xml" "$DOCSET/Contents/Resources" &&
    echo $DOCSET
}

function fetch_source_docs {
    local DST=$1 &&
    local TMP=$(mktemp './source.XXXXXX') &&

    curl -o "$TMP" "$SOURCE_URL" &&
    if [[ "$SOURCE_MD5" != "$(md5 -q "$TMP")" ]]; then
        echo "Corrupt download." &&
        return 1
    fi &&

    tar -C "$DST" -xzof "$TMP" &&
    rm "$TMP"
}

function tokenize_docs {
    ./tokenize.py "$1"
}

function build {
    local DOCSET=$(make_structure) &&
    local DOCSET_XML="$DOCSET/Contents/Resources" &&
    local DOCSET_DOC="$DOCSET/Contents/Resources/Documents" &&

    fetch_source_docs "$DOCSET_DOC" &&
    tokenize_docs "$DOCSET_DOC" > "$DOCSET_XML/Tokens.xml" &&
    $DOCSETUTIL index "$DOCSET"
}

build
