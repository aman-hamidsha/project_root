import importlib.util
import tempfile
import unittest
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[3]
MODULE_PATH = ROOT / "tools" / "ml" / "train_simulator_model.py"


def load_module():
    spec = importlib.util.spec_from_file_location("train_model_module", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class TrainSimulatorModelTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()

    def test_make_feature_text_includes_scenario_and_actions(self):
        row = pd.Series(
            {
                "scenario": "smishing",
                "actions": ["report_block", "verify_official"],
                "reply": "I will verify through the official app.",
            }
        )

        feature_text = self.module.make_feature_text(row)

        self.assertIn("scenario_smishing", feature_text)
        self.assertIn("action_report_block", feature_text)
        self.assertIn("action_verify_official", feature_text)
        self.assertIn("official app", feature_text)

    def test_train_domain_returns_expected_model_sections(self):
        df = pd.DataFrame(
            [
                {
                    "scenario": "smishing",
                    "actions": ["report_block"],
                    "reply": "I will report this scam.",
                    "label": "excellent",
                },
                {
                    "scenario": "smishing",
                    "actions": ["click_link"],
                    "reply": "I clicked the link.",
                    "label": "dangerous",
                },
                {
                    "scenario": "smishing",
                    "actions": ["verify_official"],
                    "reply": "I will verify through the official app.",
                    "label": "good",
                },
                {
                    "scenario": "smishing",
                    "actions": ["click_link", "pay_fee"],
                    "reply": "I will pay the urgent fee now.",
                    "label": "at_risk",
                },
            ]
        )

        model = self.module.train_domain(df)

        self.assertIn("labels", model)
        self.assertIn("priors", model)
        self.assertIn("likelihoods", model)
        self.assertIn("unknownLogProb", model)
        self.assertGreater(len(model["labels"]), 1)

    def test_write_dart_export_writes_named_constants(self):
        sms_model = {
            "labels": ["excellent"],
            "priors": {"excellent": -1.0},
            "likelihoods": {"excellent": {"token": -0.1}},
            "unknownLogProb": {"excellent": -2.0},
            "vocabulary": ["token"],
        }
        email_model = {
            "labels": ["dangerous"],
            "priors": {"dangerous": -1.0},
            "likelihoods": {"dangerous": {"token": -0.1}},
            "unknownLogProb": {"dangerous": -2.0},
            "vocabulary": ["token"],
        }

        with tempfile.TemporaryDirectory() as temp_dir:
            out_file = Path(temp_dir) / "generated_ml_models.dart"
            original_out_file = self.module.OUT_FILE
            try:
                self.module.OUT_FILE = out_file
                self.module.write_dart_export(sms_model, email_model)

                content = out_file.read_text(encoding="utf-8")
                self.assertIn("generatedSmsMlModel", content)
                self.assertIn("generatedEmailMlModel", content)
            finally:
                self.module.OUT_FILE = original_out_file


if __name__ == "__main__":
    unittest.main()
