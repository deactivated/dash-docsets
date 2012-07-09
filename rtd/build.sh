#!/bin/bash

function fetch {
    local PROJECT REL TMP &&
    PROJECT=$1 && shift &&
    REL=$1 && shift &&
    TMPDIR=$1 && shift &&

    echo "Downloading source" &&
    curl -o "$TMPDIR/src.zip" \
        "http://media.readthedocs.org/htmlzip/$PROJECT/$REL/$PROJECT.zip"
}

function extract {
    TMPDIR=$1 && shift &&
    (
        cd "$TMP" &&
        unzip -qq -d src "src.zip"
    )
}

function compile {
    local NAME TMPDIR ICON &&
    NAME=$1 && shift &&
    ICON=$1 && shift &&
    TMPDIR=$1 && shift &&

    if [[ -n "$ICON" ]]; then
        ICON="--icon=$ICON"
    else
        ICON="--icon=src/rtd.png"
    fi &&

    echo "Compiling docset" &&
    doc2dash -n "$NAME" \
        $ICON \
        "$(find "$TMPDIR/src" -maxdepth 1 -type d | tail -n 1)"
}

function build {
    local PROJECT REL ICON TMP &&

    while getopts “hi:” OPT; do
        case $OPT in
            i)
                ICON=$OPTARG
                ;;
            h | ?)
                usage; exit 1 ;;
         esac
    done

    shift $(( $OPTIND - 1 )) &&
    PROJECT=$1 && shift
    REL=$1 &&

    if [[ -z "$PROJECT" ]]; then
        usage; exit 1
    fi

    if [[ -z "$REL" ]]; then
        REL=latest
    fi &&

    TMP=$(mktemp -d -t "rtd") &&

    fetch "$PROJECT" "$REL" "$TMP" &&
    extract "$TMP" &&
    compile "$PROJECT $REL" "$ICON" "$TMP"

    echo "here"
    if [[ -n "$TMP" && -d "$TMP" ]]; then
        echo "cleaning up"
        rm -r "$TMP"
    fi
}

function usage {
    echo "Usage: $0 <project> [release]"
}

build "$@"
