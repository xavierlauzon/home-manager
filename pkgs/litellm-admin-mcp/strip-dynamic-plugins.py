#!/usr/bin/env python3
"""Make an sdist whose version/readme come from uv-dynamic-versioning /
hatch-fancy-pypi-readme buildable with plain hatchling: strip those plugin
sections/requires, keep/insert hatchling, set version (and readme) statically.
Usage: strip-dynamic-plugins.py <version> [pyproject.toml]
"""
import re
import sys

version = sys.argv[1]
path = sys.argv[2] if len(sys.argv) > 2 else "pyproject.toml"
s = open(path).read()


def fix_requires(m):
    items = re.findall(r'"([^"]+)"', m.group(1))
    items = [
        i for i in items
        if not i.startswith(("hatch-fancy-pypi-readme", "uv-dynamic-versioning"))
    ]
    if not any(i == "hatchling" or i.startswith("hatchling") for i in items):
        items = ["hatchling"] + items
    return "requires = [" + ", ".join('"%s"' % i for i in items) + "]"


s = re.sub(r"requires\s*=\s*\[([^\]]*)\]", fix_requires, s, count=1)

dyn = 'version = "%s"' % version
if re.search(r"^dynamic = .*readme", s, re.M):
    dyn += '\nreadme = "README.md"'
s = re.sub(r"^dynamic = .*$", dyn.replace("\\", "\\\\"), s, count=1, flags=re.M)

open(path, "w").write(s)
