#!/bin/bash

DOCSET_NAME="Emacs Lisp"
SOURCE_URL=http://www.gnu.org/software/emacs/manual/elisp.html_node.tar.gz
SOURCE_MD5=a337b69c704ff7e54fd7567f3f0de1a1

DOCSETUTIL=/Applications/Xcode.app/Contents/Developer/usr/bin/docsetutil

function make_structure {
    local DOCSET="$DOCSET_NAME.docset"
    mkdir -p "$DOCSET/Contents/Resources/Documents" &&
    cp "src/Info.plist" "$DOCSET/Contents" &&
    cp "src/Nodes.xml" "$DOCSET/Contents/Resources" &&
    cp "src/icon.png" "$DOCSET/" &&
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

function rewrite_docs {
    find "$1" -name "*html" -print0 | xargs -0 ./add_anchors.pl
}

function build {
    local DOCSET=$(make_structure) &&
    local DOCSET_XML="$DOCSET/Contents/Resources" &&
    local DOCSET_DOC="$DOCSET/Contents/Resources/Documents" &&

    fetch_source_docs "$DOCSET_DOC" &&
    tokenize_docs "$DOCSET_DOC" > "$DOCSET_XML/Tokens.xml" &&
    rewrite_docs "$DOCSET_DOC" &&
    $DOCSETUTIL index "$DOCSET"
}

build
