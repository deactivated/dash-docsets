function init_repo {
    local TMP=$1 && shift &&
    echo "cloning repo..." &&
    hg -q clone -U http://hg.sqlalchemy.org/sqlalchemy "$TMP"
}

function build_rev {
    local REPO REV TAG &&
    REPO=$1 && shift &&
    TMP=$1 && shift &&
    REV=$1 && shift &&
    TAG=$(
        cd "$REPO" &&
        hg tags | grep "rel_0_$REV" | cut -d ' ' -f 1 | head -n 1
    ) &&
    (
        echo "checking out $TAG" &&
        cd "$REPO" &&
        hg -q archive -r "$TAG" "$TMP"/"$TAG" &&

        echo "building html" &&
        cd "$TMP/$TAG/doc/build" &&
        perl -p -i -e 's/template_bridge = .*//;' conf.py &&
        sphinx-build -b html . . &> /dev/null
    ) &&
    (
        NAME="SQLAlchemy $(echo $TAG | sed -e 's/rel_//' -e 'y/_/./')" &&
        echo "building docset $NAME" &&
        doc2dash \
            -i src/icon.png \
            -n "$NAME" \
            "$TMP/$TAG/doc/build"
    )
}

function build {
    local REPO TMP &&
    REPO=$1 && shift &&

    if [[ -z "$REPO" ]]; then
        REPO=$(mktemp -d './source.XXXXXX')

    elif [[ -a "$REPO" && ! -d "$REPO/.hg" ]]; then
        return
    fi

    if [[ ! -a "$REPO/.hg" ]]; then
        echo "cloning repo..." &&
        init_repo "$REPO"
    fi

    TMP=$(cd "$(mktemp -d './source.XXXXXX')" && pwd) &&
    build_rev "$REPO" "$TMP" 7
    rm -rf "$TMP"
}

build "$@"
