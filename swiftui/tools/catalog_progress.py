#!/usr/bin/env python3
"""収録の進み具合を出す。Manifest.swift の id と、収録データ（Catalog/<トピック>/*Entry.swift）の id を突き合わせる。

使い方（swiftui/ で実行する）:
    python3 tools/catalog_progress.py                      # 全トピックの収録数と、抜けの id
    python3 tools/catalog_progress.py layout-fundamentals  # 指定したトピックだけ。抜けがあれば終了コード 1
"""
import argparse
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(HERE, "..", "WidgetLab")
MANIFEST_ENTRY = re.compile(r'ManifestEntry\(id: "([^"]+)", kind: \.\w+, topic: \.(\w+)\)')
TOPIC_CASE = re.compile(r'case (\w+) = "([^"]+)"')
# 収録の 1 件の id（プロパティの id: と区別するため、CatalogEntry( の直後のものだけ）
CATALOG_ID = re.compile(r'static let (\w+) = CatalogEntry\(\s*id:\s*"([^"]+)"')
# Catalog.all の並びの行（`.vStack,`）
ALL_NAME = re.compile(r'^\s*\.(\w+),\s*$', re.MULTILINE)


def read_manifest(app_dir):
    """[(id, トピックの slug), ...] を Manifest.swift の並びで返す"""
    generated = os.path.join(app_dir, "Catalog", "Generated")
    with open(os.path.join(generated, "Topic.swift"), encoding="utf-8") as f:
        slugs = dict(TOPIC_CASE.findall(f.read()))
    with open(os.path.join(generated, "Manifest.swift"), encoding="utf-8") as f:
        return [(entry_id, slugs[case]) for entry_id, case in MANIFEST_ENTRY.findall(f.read())]


def read_catalog_ids(app_dir):
    """(Catalog.all に並べた収録の id の集合, ファイルはあるが all にない id のリスト)"""
    declared = {}
    for path in glob.glob(os.path.join(app_dir, "Catalog", "*", "*Entry.swift")):
        with open(path, encoding="utf-8") as f:
            for name, entry_id in CATALOG_ID.findall(f.read()):
                declared[name] = entry_id
    with open(os.path.join(app_dir, "Catalog", "Catalog.swift"), encoding="utf-8") as f:
        text = f.read()
    start = text.find("static let all")
    listed = set(ALL_NAME.findall(text[start:] if start >= 0 else ""))
    ids = {entry_id for name, entry_id in declared.items() if name in listed}
    unlisted = sorted(entry_id for name, entry_id in declared.items() if name not in listed)
    return ids, unlisted


def progress(manifest, catalog_ids):
    """{slug: (収録数, 全数, [抜けの id])} をトピックの並び（Manifest に最初に出てきた順）で返す"""
    result = {}
    for entry_id, slug in manifest:
        done, total, missing = result.get(slug, (0, 0, []))
        if entry_id in catalog_ids:
            done += 1
        else:
            missing = missing + [entry_id]
        result[slug] = (done, total + 1, missing)
    return result


def report(rows, unlisted=()):
    lines = []
    for slug, (done, total, missing) in rows.items():
        lines.append("{:<28} {:>3} / {:<3}".format(slug, done, total))
        if missing:
            lines.append("    抜け: " + ", ".join(missing))
    if unlisted:
        lines.append("Catalog.all にない: " + ", ".join(unlisted))
    done = sum(r[0] for r in rows.values())
    total = sum(r[1] for r in rows.values())
    lines.append("合計 {} / {}（抜け {}）".format(done, total, total - done))
    return "\n".join(lines)


def main(argv=None, app_dir=APP_DIR):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("topics", nargs="*", help="トピックの slug（例: layout-fundamentals）。省くと全部")
    args = parser.parse_args(argv)
    catalog_ids, unlisted = read_catalog_ids(app_dir)
    rows = progress(read_manifest(app_dir), catalog_ids)
    unknown = [t for t in args.topics if t not in rows]
    if unknown:
        print("Manifest にないトピック: " + ", ".join(unknown), file=sys.stderr)
        return 2
    if args.topics:
        rows = {slug: rows[slug] for slug in args.topics}
    print(report(rows, unlisted))
    return 1 if unlisted or (args.topics and any(r[2] for r in rows.values())) else 0


if __name__ == "__main__":
    sys.exit(main())
