#!/usr/bin/env python

import re
import sys
import os
import argparse


def extract_tokens(data):
    type_map = {
        "Function": "func",
        "Command": "func",
        "Special Form": "func",
        "Variable": "instp"
    }

    for symbol_type, symbol_name, symbol_link in re.findall(
            r"""
            &mdash;\s*(?P<type>[\w-]+):\s*<b>(?P<name>[\w-]+)</b>
            .*?
            <a\s*name="(?P<anchor>.*?)">
            """,
            data, re.X):

        if symbol_type in type_map:
            yield {
                "type": type_map[symbol_type],
                "name": symbol_name,
                "link": symbol_link
            }


def print_plist(root_dir, out_f=sys.stdout):
    def print_dir(arg, dirname, names):
        for name in names:
            path = os.path.join(dirname, name)
            if os.path.isfile(path):
                print_file(path)


    def print_file(path):
        rel = os.path.relpath(path, root_dir)

        print >>out_f, '<File path="%s">' % rel
        for token in extract_tokens(open(path).read()):
            print >>out_f, ('<Token>'
                            '<TokenIdentifier>//apple_ref/cpp/%(type)s/%(name)s</TokenIdentifier>'
                            '<Anchor>%(link)s</Anchor>'
                            '</Token>' % token)
        print >>out_f, '</File>'


    print >>out_f, '<?xml version="1.0" encoding="UTF-8"?>'
    print >>out_f, '<Tokens version="1.0">'
    os.path.walk(root_dir, print_dir, None)
    print >>out_f, "</Tokens>"


def main():
    p = argparse.ArgumentParser(description=('Generate a Tokens.xml from the '
                                             'elisp reference docs.'))
    p.add_argument('path', metavar='PATH', default='.',
                   help='path to extracted elisp reference manual')
    p.add_argument('--output', '-o', dest='filename', default='-',
                   help='output filename')

    args = p.parse_args()

    if args.filename == "-":
        out_f = sys.stdout
    else:
        out_f = open(args.filename, "w")

    path = os.path.abspath(args.path)
    assert os.path.isdir(path)

    print_plist(path, out_f)


if __name__ == '__main__':
    main()
