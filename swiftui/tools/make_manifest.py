#!/usr/bin/env python3
"""SwiftUI のリファレンスの JSON から Topic.swift と Manifest.swift を作る。

数え方は docs/superpowers/specs/2026-10-31-swiftui-app-design.md の「数え方」のとおり。
使い方（swiftui/ で実行する）:
    python3 tools/make_manifest.py            # キャッシュになければ取り出してから作る
    python3 tools/make_manifest.py --refresh  # キャッシュを取り直してから作る
"""
import argparse
import json
import os
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE_URL = "https://developer.apple.com/tutorials/data"
ROOT_URL = "/documentation/swiftui"
CATEGORIES = [
    "Views",
    "View layout",
    "App structure",
    "Data and storage",
    "Event handling",
    "Accessibility",
]
TARGET_IOS = (27, 0)
# 型の都合の型（書いて使うものではなく、modifier や型消去の結果の型）。収録しない
EXCLUDED_TYPES = {
    "AnyGesture",
    "AnyShape",
    "AnyView",
    "ButtonBorderShape",
    "DefaultButtonLabel",
    "DefaultDateProgressLabel",
    "DefaultDocumentGroupLaunchActions",
    "DefaultGlassEffectShape",
    "DefaultNewDocumentButtonLabel",
    "EditableCollectionContent",
    "EmptyView",
    "EquatableView",
    "FillShapeView",
    "GestureStateGesture",
    "GroupElementsOfContent",
    "GroupSectionsOfContent",
    "ModifiedContent",
    "OffsetShape",
    "PlaceholderContentView",
    "RotatedShape",
    "ScaledShape",
    "StrokeBorderShapeView",
    "StrokeShapeView",
    "SubscriptionView",
    "Subview",
    "SubviewsCollection",
    "SubviewsCollectionSlice",
    "TextInputBorderShape",
    "TransformedShape",
    "TupleContent",
    "TupleView",
}

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = os.path.join(HERE, ".cache")
OUT_DIR = os.path.join(HERE, "..", "WidgetLab", "Catalog", "Generated")


# --- 数え方（通信しない。テストはここを確かめる） ---

def parse_version(text):
    parts = [int(p) for p in re.findall(r"\d+", text or "")]
    return tuple((parts + [0, 0])[:2])


def ios_available(symbol):
    """iOS で使え、非推奨でなく、導入の版が TARGET_IOS 以下なら True。"""
    for platform in symbol.get("metadata", {}).get("platforms", []):
        if platform.get("name") != "iOS":
            continue
        if platform.get("deprecated") or platform.get("unavailable"):
            return False
        return parse_version(platform.get("introducedAt")) <= TARGET_IOS
    return False


def conformances(symbol):
    names = []
    for section in symbol.get("relationshipsSections", []):
        if section.get("type") == "conformsTo":
            names += [i.split("/")[-1].lower() for i in section.get("identifiers", [])]
    return names


def kind_of(url, symbol):
    """収録の種類（"view" / "modifier" / "propertyWrapper" / "gesture"）か None。"""
    if not ios_available(symbol):
        return None
    meta = symbol.get("metadata", {})
    symbol_kind = meta.get("symbolKind")
    if symbol_kind == "method":
        return "modifier" if url.startswith(ROOT_URL + "/view/") else None
    if symbol_kind != "struct" or meta.get("title") in EXCLUDED_TYPES:
        return None
    conf = conformances(symbol)
    if "view" in conf:
        return "view"
    if "dynamicproperty" in conf:
        return "propertyWrapper"
    if "gesture" in conf:
        return "gesture"
    return None


def entry_id(kind, title):
    return title.split("(")[0] if kind == "modifier" else title


def topic_case(slug):
    words = re.split(r"[-_]", slug)
    return words[0].lower() + "".join(w[:1].upper() + w[1:] for w in words[1:])


def classify(root, topics, symbols):
    """リファレンスの JSON から、トピックの一覧と収録すべきものの一覧を返す。

    root: swiftui.json / topics: トピックの URL → JSON / symbols: 記号の URL → JSON
    戻り値: (topics, entries)
      topics: [{"slug", "title", "category"}]（収録が 1 件以上あるものだけ、リファレンスの順）
      entries: [{"id", "kind", "topic"}]（リファレンスの順）
    """
    refs = root.get("references", {})
    seen_urls = set()
    seen_ids = set()
    entries = []
    topic_list = []
    for section in root.get("topicSections", []):
        if section.get("title") not in CATEGORIES:
            continue
        for ident in section.get("identifiers", []):
            ref = refs.get(ident, {})
            topic_url = ref.get("url", "")
            topic = topics.get(topic_url)
            if topic is None:
                continue
            slug = topic_url.split("/")[-1]
            topic_refs = topic.get("references", {})
            count = 0
            for group in topic.get("topicSections", []):
                found = []
                for sym_ident in group.get("identifiers", []):
                    sym_ref = topic_refs.get(sym_ident, {})
                    url = sym_ref.get("url", "")
                    if sym_ref.get("role") != "symbol" or url in seen_urls:
                        continue
                    seen_urls.add(url)
                    symbol = symbols.get(url)
                    kind = kind_of(url, symbol) if symbol else None
                    if kind:
                        found.append((kind, entry_id(kind, symbol["metadata"]["title"])))
                has_view = any(kind == "view" for kind, _ in found)
                for kind, name in found:
                    if kind == "modifier" and has_view:
                        continue  # View の節の modifier は、その View のプロパティにする
                    if name in seen_ids:
                        continue
                    seen_ids.add(name)
                    entries.append({"id": name, "kind": kind, "topic": slug})
                    count += 1
            if count:
                topic_list.append(
                    {"slug": slug, "title": ref.get("title", slug), "category": section["title"]}
                )
    return topic_list, entries


# --- Swift のファイルを書く ---

HEADER = "// 生成: tools/make_manifest.py（手で直さない）\n\n"


def swift_string(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def render_topics(topic_list):
    lines = [HEADER.rstrip("\n"), "", "/// リファレンスの大分類。並びはホームに出す順"]
    lines.append("nonisolated enum Category: String, CaseIterable, Sendable {")
    for name in CATEGORIES:
        if any(t["category"] == name for t in topic_list):
            lines.append("    case {} = {}".format(topic_case(name.replace(" ", "-")), swift_string(name)))
    lines += ["}", "", "/// リファレンスのトピック（= ジャンル）。収録が 1 件以上あるものだけ。並びはリファレンスの順"]
    lines.append("nonisolated enum Topic: String, CaseIterable, Sendable {")
    for t in topic_list:
        lines.append("    case {} = {}".format(topic_case(t["slug"]), swift_string(t["slug"])))
    lines += ["", "    var title: String {", "        switch self {"]
    for t in topic_list:
        lines.append("        case .{}: {}".format(topic_case(t["slug"]), swift_string(t["title"])))
    lines += ["        }", "    }", "", "    var category: Category {", "        switch self {"]
    for t in topic_list:
        lines.append(
            "        case .{}: .{}".format(topic_case(t["slug"]), topic_case(t["category"].replace(" ", "-")))
        )
    lines += ["        }", "    }", "}", ""]
    return "\n".join(lines)


def render_manifest(entries):
    lines = [HEADER.rstrip("\n"), "", "/// 収録すべきものの一覧。Catalog.all と突き合わせる"]
    lines += ["nonisolated enum Manifest {", "    static let entries: [ManifestEntry] = ["]
    for e in entries:
        lines.append(
            "        ManifestEntry(id: {}, kind: .{}, topic: .{}),".format(
                swift_string(e["id"]), e["kind"], topic_case(e["topic"])
            )
        )
    lines += ["    ]", "}", ""]
    return "\n".join(lines)


# --- 取り出し（通信する） ---

def cache_path(url):
    return os.path.join(CACHE_DIR, re.sub(r"[^A-Za-z0-9._-]", "_", url.strip("/")) + ".json")


def load(url, refresh):
    path = cache_path(url)
    if refresh or not os.path.exists(path):
        with urllib.request.urlopen(BASE_URL + url.lower() + ".json", timeout=30) as response:
            data = response.read()
        with open(path, "wb") as f:
            f.write(data)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def load_all(urls, refresh):
    with ThreadPoolExecutor(16) as pool:
        return dict(zip(urls, pool.map(lambda u: load(u, refresh), urls)))


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh", action="store_true", help="キャッシュを取り直す")
    args = parser.parse_args(argv)
    os.makedirs(CACHE_DIR, exist_ok=True)

    root = load(ROOT_URL, args.refresh)
    refs = root.get("references", {})
    topic_urls = [
        refs[i]["url"]
        for s in root.get("topicSections", [])
        if s.get("title") in CATEGORIES
        for i in s.get("identifiers", [])
        if i in refs
    ]
    topics = load_all(topic_urls, args.refresh)
    symbol_urls = sorted(
        {
            r["url"]
            for t in topics.values()
            for r in t.get("references", {}).values()
            if r.get("role") == "symbol" and r.get("url", "").startswith(ROOT_URL + "/")
        }
    )
    symbols = load_all(symbol_urls, args.refresh)

    topic_list, entries = classify(root, topics, symbols)
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, "Topic.swift"), "w", encoding="utf-8") as f:
        f.write(render_topics(topic_list))
    with open(os.path.join(OUT_DIR, "Manifest.swift"), "w", encoding="utf-8") as f:
        f.write(render_manifest(entries))
    counts = {}
    for e in entries:
        counts[e["kind"]] = counts.get(e["kind"], 0) + 1
    print("トピック {} 件 / 収録 {} 件 {}".format(len(topic_list), len(entries), counts))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
