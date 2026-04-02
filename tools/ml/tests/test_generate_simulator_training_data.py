import importlib.util
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
MODULE_PATH = ROOT / "tools" / "ml" / "generate_simulator_training_data.py"


def load_module():
    spec = importlib.util.spec_from_file_location("generate_data_module", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class GenerateSimulatorTrainingDataTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()

    def test_build_record_keeps_expected_shape(self):
        record = self.module.build_record(
            domain="sms",
            scenario="smishing",
            actions=["report_block"],
            reply="I will report this.",
            label="excellent",
        )

        self.assertEqual(record["domain"], "sms")
        self.assertEqual(record["scenario"], "smishing")
        self.assertEqual(record["actions"], ["report_block"])
        self.assertEqual(record["label"], "excellent")

    def test_generate_domain_records_produces_all_labels(self):
        records = self.module.generate_domain_records("sms", self.module.SMS_SCENARIOS)

        labels = {record["label"] for record in records}
        scenarios = {record["scenario"] for record in records}

        self.assertIn("dangerous", labels)
        self.assertIn("at_risk", labels)
        self.assertIn("good", labels)
        self.assertIn("excellent", labels)
        self.assertEqual(scenarios, set(self.module.SMS_SCENARIOS.keys()))

    def test_main_writes_jsonl_file(self):
        with tempfile.TemporaryDirectory() as temp_dir:
          out_dir = Path(temp_dir)
          out_file = out_dir / "simulator_training_data.jsonl"

          original_out_dir = self.module.OUT_DIR
          original_out_file = self.module.OUT_FILE
          try:
              self.module.OUT_DIR = out_dir
              self.module.OUT_FILE = out_file
              self.module.main()

              self.assertTrue(out_file.exists())
              lines = out_file.read_text(encoding="utf-8").strip().splitlines()
              self.assertGreater(len(lines), 50)
          finally:
              self.module.OUT_DIR = original_out_dir
              self.module.OUT_FILE = original_out_file


if __name__ == "__main__":
    unittest.main()
