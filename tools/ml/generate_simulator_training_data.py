#!/usr/bin/env python3
"""Generate synthetic training data for simulator response analysis.

This intentionally uses only the Python standard library so it can run in
lightweight environments. The output is synthetic and designed for coursework /
prototype ML concepts, not production-grade security classification.
"""

from __future__ import annotations

import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "ml" / "data"
OUT_FILE = OUT_DIR / "simulator_training_data.jsonl"


def build_record(
    *,
    domain: str,
    scenario: str,
    actions: list[str],
    reply: str,
    label: str,
) -> dict[str, object]:
    return {
        "domain": domain,
        "scenario": scenario,
        "actions": actions,
        "reply": reply,
        "label": label,
    }


SMS_SCENARIOS = {
    "campusSafe": {
        "safe_actions": [["check_app"], ["ignore_delete"], ["check_app", "ignore_delete"]],
        "risky_actions": [["reply_yes"]],
        "excellent_replies": [
            "Thanks, I will check the official app.",
            "Okay, I will review it in the student app.",
            "Got it, I will use the normal portal later.",
        ],
        "good_replies": [
            "Thanks, I will check.",
            "Okay, noted.",
            "I will look in the app.",
        ],
        "risky_replies": [
            "send me my password reset code",
            "can i pay here",
            "what is my account code",
        ],
    },
    "smishing": {
        "safe_actions": [["report_block"], ["verify_official"], ["report_block", "verify_official"]],
        "risky_actions": [["click_link"], ["pay_fee"], ["click_link", "pay_fee"]],
        "excellent_replies": [
            "This looks suspicious. I will report it and check the official courier app.",
            "I won't click that link. I will verify through the real site.",
            "Scam message. Reporting and ignoring.",
        ],
        "good_replies": [
            "I will check the official delivery app first.",
            "This seems suspicious so I will not click.",
            "I am going to report this text.",
        ],
        "risky_replies": [
            "I will click now and pay the fee.",
            "urgent parcel fee, I will pay now",
            "send me the payment page please",
        ],
    },
    "fraudAlert": {
        "safe_actions": [["contact_known_channel"], ["report_block"], ["contact_known_channel", "report_block"]],
        "risky_actions": [["share_code"], ["share_personal_info"], ["share_code", "share_personal_info"]],
        "excellent_replies": [
            "I won't share any code. I will call the bank using the number on my card.",
            "This is suspicious. I will report it and use the banking app directly.",
            "Scam alert. I am contacting the real bank myself.",
        ],
        "good_replies": [
            "I will call my bank first.",
            "This seems suspicious so I will verify separately.",
            "I am not sending anything by text.",
        ],
        "risky_replies": [
            "My code is 221144 and my dob is tomorrow.",
            "I will confirm my birthday and code now.",
            "Here are my details so stop the transfer.",
        ],
    },
    "jobScam": {
        "safe_actions": [["ignore_delete"], ["ask_for_identity"]],
        "risky_actions": [["reply_yes"], ["share_personal_info"], ["reply_yes", "share_personal_info"]],
        "excellent_replies": [
            "This sounds suspicious. I will not reply and I will verify the company first.",
            "No thanks, this looks like a scam job text.",
            "I am ignoring this until I can confirm the employer.",
        ],
        "good_replies": [
            "What company is this?",
            "I need more information before I respond.",
            "I will verify the employer first.",
        ],
        "risky_replies": [
            "YES I want the job, here is my full name and whatsapp.",
            "I will register now and send my details.",
            "Sure, here is my number and full name.",
        ],
    },
    "friendInNeed": {
        "safe_actions": [["contact_known_channel"], ["ask_for_identity"]],
        "risky_actions": [["buy_gift_card"], ["reply_yes"], ["buy_gift_card", "reply_yes"]],
        "excellent_replies": [
            "I will call your old number to verify this first.",
            "This is suspicious. I won't buy anything until I confirm it is really you.",
            "No, I will verify through another channel.",
        ],
        "good_replies": [
            "Who is this exactly?",
            "I need to verify before helping.",
            "I will call you first.",
        ],
        "risky_replies": [
            "Sure I will buy the gift card and send the code now.",
            "Okay, I can do that right away.",
            "I will send the gift card details soon.",
        ],
    },
}


EMAIL_SCENARIOS = {
    "campusSafe": {
        "safe_actions": [["open_real_site"], ["ignore"]],
        "risky_actions": [["reply_question"]],
        "excellent_replies": [
            "Thanks, I will check the portal from my bookmark.",
            "Okay, I will review this in the normal student portal.",
            "I will use the official site directly.",
        ],
        "good_replies": [
            "Thanks, noted.",
            "I will check later.",
            "Okay, I will review it.",
        ],
        "risky_replies": [
            "please send me my password and code",
            "email me my bank details",
            "reply with my login info",
        ],
    },
    "accountPhishing": {
        "safe_actions": [["open_real_site"], ["report_delete"], ["open_real_site", "report_delete"]],
        "risky_actions": [["click_link"], ["send_credentials"], ["click_link", "send_credentials"]],
        "excellent_replies": [
            "This is suspicious. I won't click it and I will report it.",
            "I will open the real Microsoft site from my bookmark and verify separately.",
            "Phishing attempt. Reporting and deleting.",
        ],
        "good_replies": [
            "I will verify through the official site.",
            "This looks suspicious so I will not click.",
            "I am reporting this email.",
        ],
        "risky_replies": [
            "I clicked the link and entered my password.",
            "I will verify now through the link.",
            "sending my login code now",
        ],
    },
    "payrollScam": {
        "safe_actions": [["call_known_contact"], ["report_internal"], ["call_known_contact", "report_internal"]],
        "risky_actions": [["open_attachment"], ["send_bank_info"], ["open_attachment", "send_bank_info"]],
        "excellent_replies": [
            "I will contact payroll through the known company channel before doing anything.",
            "This looks suspicious. I will report it internally and not open the attachment.",
            "I am verifying with payroll directly, not through this email.",
        ],
        "good_replies": [
            "I need to verify this with payroll first.",
            "This attachment seems suspicious.",
            "I will report this to the internal team.",
        ],
        "risky_replies": [
            "I opened the form and sent my bank details.",
            "sending account information now",
            "I will complete the attachment today",
        ],
    },
    "parcelFee": {
        "safe_actions": [["verify_official"], ["report_delete"], ["verify_official", "report_delete"]],
        "risky_actions": [["click_link"], ["send_bank_info"], ["click_link", "send_bank_info"]],
        "excellent_replies": [
            "I won't pay through the email. I will check the real courier account.",
            "This looks like a parcel scam. Reporting and deleting.",
            "I will verify through the official courier app only.",
        ],
        "good_replies": [
            "I will check the courier separately.",
            "This is suspicious so I will not click.",
            "I will report this email.",
        ],
        "risky_replies": [
            "I clicked and paid the fee with my card.",
            "I will enter my card details now.",
            "send me the payment page again",
        ],
    },
    "ceoImpersonation": {
        "safe_actions": [["call_known_contact"], ["report_internal"], ["call_known_contact", "report_internal"]],
        "risky_actions": [["buy_gift_cards"], ["reply_question", "buy_gift_cards"]],
        "excellent_replies": [
            "I will verify this with the CEO through a trusted number before doing anything.",
            "This looks like impersonation. Reporting internally.",
            "I will not buy gift cards from an email request.",
        ],
        "good_replies": [
            "I need to verify this request first.",
            "This seems suspicious so I will call directly.",
            "I will escalate this internally.",
        ],
        "risky_replies": [
            "I bought the gift cards and will send the codes.",
            "I will keep this private and handle it now.",
            "Sure, I can buy the cards today.",
        ],
    },
}


def generate_domain_records(domain: str, scenarios: dict[str, dict[str, list[list[str]] | list[str]]]) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for scenario, config in scenarios.items():
        safe_actions = config["safe_actions"]
        risky_actions = config["risky_actions"]
        excellent_replies = config["excellent_replies"]
        good_replies = config["good_replies"]
        risky_replies = config["risky_replies"]

        for _ in range(48):
            actions = random.choice(safe_actions)
            reply = random.choice(excellent_replies)
            records.append(
                build_record(
                    domain=domain,
                    scenario=scenario,
                    actions=actions,
                    reply=reply,
                    label="excellent",
                )
            )

        for _ in range(40):
            actions = random.choice(safe_actions + [[]])
            reply = random.choice(good_replies)
            records.append(
                build_record(
                    domain=domain,
                    scenario=scenario,
                    actions=actions,
                    reply=reply,
                    label="good",
                )
            )

        for _ in range(34):
            actions = random.choice(safe_actions + risky_actions)
            reply = random.choice(good_replies + risky_replies)
            records.append(
                build_record(
                    domain=domain,
                    scenario=scenario,
                    actions=actions,
                    reply=reply,
                    label="at_risk",
                )
            )

        for _ in range(42):
            actions = random.choice(risky_actions)
            reply = random.choice(risky_replies)
            records.append(
                build_record(
                    domain=domain,
                    scenario=scenario,
                    actions=actions,
                    reply=reply,
                    label="dangerous",
                )
            )
    return records


def main() -> None:
    random.seed(310)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    records = generate_domain_records("sms", SMS_SCENARIOS) + generate_domain_records("email", EMAIL_SCENARIOS)
    random.shuffle(records)

    with OUT_FILE.open("w", encoding="utf-8") as handle:
      for record in records:
        handle.write(json.dumps(record) + "\n")

    print(f"Wrote {len(records)} synthetic samples to {OUT_FILE}")


if __name__ == "__main__":
    main()
