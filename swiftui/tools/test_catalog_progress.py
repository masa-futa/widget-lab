"""catalog_progress.py のテスト。swiftui/ で `python3 -m unittest discover tools` で実行する。"""
import os
import tempfile
import unittest

import catalog_progress as cp

TOPIC_SWIFT = """nonisolated enum Topic: String, CaseIterable, Sendable {
    case layoutFundamentals = "layout-fundamentals"
    case gestures = "gestures"
"""
MANIFEST_SWIFT = """        ManifestEntry(id: "VStack", kind: .view, topic: .layoutFundamentals),
        ManifestEntry(id: "HStack", kind: .view, topic: .layoutFundamentals),
        ManifestEntry(id: "TapGesture", kind: .gesture, topic: .gestures),
"""
ENTRY_SWIFT = """    static let vStack = CatalogEntry(
        id: "VStack",
        properties: [
            .modifier("frame", id: "HStack", label: "width", .slider(range: 0...1, step: 1, initial: 0), summary: ""),
        ],
"""


class CatalogProgressTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        self.app = self.dir.name
        self.write("Catalog/Generated/Topic.swift", TOPIC_SWIFT)
        self.write("Catalog/Generated/Manifest.swift", MANIFEST_SWIFT)
        self.write("Catalog/LayoutFundamentals/VStackEntry.swift", ENTRY_SWIFT)

    def tearDown(self):
        self.dir.cleanup()

    def write(self, path, text):
        full = os.path.join(self.dir.name, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w", encoding="utf-8") as f:
            f.write(text)

    def test_counts_by_topic_and_ignores_property_ids(self):
        rows = cp.progress(cp.read_manifest(self.app), cp.read_catalog_ids(self.app))
        self.assertEqual(
            rows,
            {"layout-fundamentals": (1, 2, ["HStack"]), "gestures": (0, 1, ["TapGesture"])},
        )

    def test_report_shows_missing_and_total(self):
        text = cp.report({"layout-fundamentals": (1, 2, ["HStack"])})
        self.assertIn("抜け: HStack", text)
        self.assertIn("合計 1 / 2（抜け 1）", text)

    def test_exit_code_is_1_only_when_selected_topics_have_missing(self):
        self.write("Catalog/Gestures/TapGestureEntry.swift", 'CatalogEntry(\n        id: "TapGesture",')
        self.assertEqual(cp.main(["gestures"], app_dir=self.app), 0)
        self.assertEqual(cp.main(["layout-fundamentals"], app_dir=self.app), 1)
        self.assertEqual(cp.main([], app_dir=self.app), 0)
        self.assertEqual(cp.main(["nope"], app_dir=self.app), 2)


if __name__ == "__main__":
    unittest.main()
