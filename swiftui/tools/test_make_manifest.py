"""make_manifest.py の数え方のテスト。swiftui/ で `python3 -m unittest discover tools` で実行する。"""
import unittest

import make_manifest as mm

ROOT = "/documentation/swiftui"


def symbol(title, kind, conforms=(), ios="17.0", deprecated=False, ios_missing=False):
    platforms = [] if ios_missing else [{"name": "iOS", "introducedAt": ios, "deprecated": deprecated}]
    return {
        "metadata": {"title": title, "symbolKind": kind, "platforms": platforms},
        "relationshipsSections": [
            {"type": "conformsTo", "identifiers": ["doc://x/" + c for c in conforms]}
        ],
    }


def topic(sections):
    """sections: [[(url, title), ...], ...]"""
    refs = {}
    topic_sections = []
    for items in sections:
        ids = []
        for url, title in items:
            refs["id:" + url] = {"url": url, "title": title, "role": "symbol"}
            ids.append("id:" + url)
        topic_sections.append({"title": "s", "identifiers": ids})
    return {"topicSections": topic_sections, "references": refs}


def root(categories):
    """categories: [(category, [(topic_url, title), ...]), ...]"""
    refs = {}
    sections = []
    for name, items in categories:
        ids = []
        for url, title in items:
            refs["id:" + url] = {"url": url, "title": title}
            ids.append("id:" + url)
        sections.append({"title": name, "identifiers": ids})
    return {"topicSections": sections, "references": refs}


class ClassifyTests(unittest.TestCase):
    def run_classify(self, sections, symbols, category="Views"):
        r = root([(category, [(ROOT + "/controls", "Controls")])])
        return mm.classify(r, {ROOT + "/controls": topic(sections)}, symbols)

    def test_view_section_modifiers_become_properties(self):
        symbols = {
            ROOT + "/button": symbol("Button", "struct", ["View"]),
            ROOT + "/view/buttonstyle(_:)": symbol("buttonStyle(_:)", "method"),
        }
        _, entries = self.run_classify(
            [[(ROOT + "/button", "Button"), (ROOT + "/view/buttonstyle(_:)", "buttonStyle(_:)")]], symbols
        )
        self.assertEqual(entries, [{"id": "Button", "kind": "view", "topic": "controls"}])

    def test_modifiers_without_view_are_entries_and_overloads_merge(self):
        symbols = {
            ROOT + "/view/padding(_:)": symbol("padding(_:)", "method"),
            ROOT + "/view/padding(_:_:)": symbol("padding(_:_:)", "method"),
        }
        _, entries = self.run_classify(
            [[(ROOT + "/view/padding(_:)", "padding(_:)"), (ROOT + "/view/padding(_:_:)", "padding(_:_:)")]],
            symbols,
        )
        self.assertEqual(entries, [{"id": "padding", "kind": "modifier", "topic": "controls"}])

    def test_excludes_newer_deprecated_missing_and_helper_types(self):
        symbols = {
            ROOT + "/new": symbol("NewView", "struct", ["View"], ios="27.1"),
            ROOT + "/old": symbol("OldView", "struct", ["View"], deprecated=True),
            ROOT + "/mac": symbol("MacView", "struct", ["View"], ios_missing=True),
            ROOT + "/anyview": symbol("AnyView", "struct", ["View"]),
            ROOT + "/style": symbol("BorderedButtonStyle", "struct", ["PrimitiveButtonStyle"]),
        }
        _, entries = self.run_classify([[(u, "x") for u in symbols]], symbols)
        self.assertEqual(entries, [])

    def test_property_wrappers_and_gestures(self):
        symbols = {
            ROOT + "/state": symbol("State", "struct", ["DynamicProperty"]),
            ROOT + "/tapgesture": symbol("TapGesture", "struct", ["Gesture"]),
        }
        _, entries = self.run_classify([[(u, "x") for u in symbols]], symbols)
        self.assertEqual(
            [(e["id"], e["kind"]) for e in entries], [("State", "propertyWrapper"), ("TapGesture", "gesture")]
        )

    def test_first_topic_wins_and_empty_topics_are_dropped(self):
        a, b, c = ROOT + "/a", ROOT + "/b", ROOT + "/c"
        r = root([("Views", [(a, "A"), (b, "B")]), ("Tool support", [(c, "C")])])
        text = ROOT + "/text"
        symbols = {text: symbol("Text", "struct", ["View"])}
        topics = {a: topic([[(text, "Text")]]), b: topic([[(text, "Text")]]), c: topic([[(text, "Text")]])}
        topic_list, entries = mm.classify(r, topics, symbols)
        self.assertEqual(topic_list, [{"slug": "a", "title": "A", "category": "Views"}])
        self.assertEqual(entries, [{"id": "Text", "kind": "view", "topic": "a"}])


class RenderTests(unittest.TestCase):
    def test_topic_case(self):
        self.assertEqual(mm.topic_case("Controls-and-indicators"), "controlsAndIndicators")
        self.assertEqual(mm.topic_case("View-layout"), "viewLayout")

    def test_render_manifest(self):
        text = mm.render_manifest([{"id": "Button", "kind": "view", "topic": "Controls-and-indicators"}])
        self.assertIn('ManifestEntry(id: "Button", kind: .view, topic: .controlsAndIndicators),', text)


if __name__ == "__main__":
    unittest.main()
