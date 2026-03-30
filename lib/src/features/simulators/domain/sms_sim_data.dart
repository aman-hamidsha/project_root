import 'sms_sim_models.dart';

const List<SmsThread> smsThreads = [
  SmsThread(
    id: 'campus_safe',
    contact: 'Campus Safety',
    phoneNumber: '+44 7700 900111',
    preview:
        'Routine campus weather update and timetable reminder for tomorrow morning.',
    kind: SmsKind.safe,
    scamType: 'Legitimate service alert',
    scenario: 'General campus information',
    riskLevel: 'Low risk',
    timeLabel: '09:14',
    messages: [
      SmsMessage(
        text:
            'Campus Safety: Light snow expected after 7AM. Please leave extra time for travel and check your timetable in the official student app if needed.',
        timestamp: '09:12',
        incoming: true,
      ),
    ],
    flags: [
      'The message is informational and does not create panic or demand immediate action.',
      'It points you toward the normal student app rather than a random login link.',
      'No passwords, codes, or payment requests are involved.',
    ],
    actions: [
      'Open the official app yourself if you want to verify the update.',
      'Treat even real texts as prompts, not direct login pathways.',
      'Keep using your known official channels for timetable or safety information.',
    ],
    decisionOptions: [
      SmsDecisionOption(
        id: 'check_app',
        label: 'Check app',
        description: 'Open the official student app yourself.',
      ),
      SmsDecisionOption(
        id: 'ignore_delete',
        label: 'Ignore',
        description: 'Do nothing and move on.',
      ),
      SmsDecisionOption(
        id: 'reply_yes',
        label: 'Reply',
        description: 'Send a quick acknowledgment.',
      ),
    ],
  ),
  SmsThread(
    id: 'delivery_fee',
    contact: 'Royal Mail Parcel',
    phoneNumber: '+44 7412 113580',
    preview:
        'Your parcel is held due to an unpaid redelivery fee. Pay now to avoid return.',
    kind: SmsKind.smishing,
    scamType: 'Delivery fee scam',
    scenario: 'Package redelivery bait',
    riskLevel: 'High risk',
    timeLabel: '11:03',
    messages: [
      SmsMessage(
        text:
            'RoyalMail: We could not deliver your parcel today. A £1.45 redelivery fee is due. Pay now at rm-fees-track-parcel.com to avoid return.',
        timestamp: '11:01',
        incoming: true,
      ),
      SmsMessage(
        text:
            'Final notice: your parcel will be destroyed if you do not complete payment in the next 20 minutes.',
        timestamp: '11:04',
        incoming: true,
      ),
    ],
    flags: [
      'The domain does not match the official organization and uses fee-themed wording to look believable.',
      'Tiny payment amounts are common because they make people drop their guard.',
      'The message creates urgency and consequences to force a quick click.',
      'Scammers often send follow-up texts when you reply, which confirms your number is active.',
    ],
    actions: [
      'Do not open the link or enter payment details.',
      'Check your real delivery account or app manually if you are expecting a parcel.',
      'Report the message as spam or smishing and block the sender.',
    ],
    decisionOptions: [
      SmsDecisionOption(
        id: 'verify_official',
        label: 'Verify',
        description: 'Check the delivery service from the official app/site.',
      ),
      SmsDecisionOption(
        id: 'report_block',
        label: 'Report',
        description: 'Report spam and block the sender.',
      ),
      SmsDecisionOption(
        id: 'click_link',
        label: 'Open link',
        description: 'Open the delivery link from the message.',
      ),
      SmsDecisionOption(
        id: 'pay_fee',
        label: 'Pay fee',
        description: 'Pay the small redelivery charge.',
      ),
    ],
  ),
  SmsThread(
    id: 'bank_verify',
    contact: 'SecureBank Alerts',
    phoneNumber: '+44 7920 445812',
    preview:
        'Suspicious transfer detected. Verify your identity immediately to stop account suspension.',
    kind: SmsKind.fraud,
    scamType: 'Fake bank verification',
    scenario: 'Account freeze threat',
    riskLevel: 'High risk',
    timeLabel: '18:27',
    messages: [
      SmsMessage(
        text:
            'SecureBank: We detected a transfer attempt for £846.31. If this was not you, verify now at securebank-check-transfer.net or your account will be frozen.',
        timestamp: '18:24',
        incoming: true,
      ),
      SmsMessage(
        text:
            'Yes. Confirm your date of birth and online banking code now so we can cancel it.',
        timestamp: '18:27',
        incoming: true,
      ),
    ],
    flags: [
      'Banks do not ask for full login codes or personal secrets through text.',
      'The link domain is unrelated to the real bank brand.',
      'The attacker escalates from a fake alert into direct credential collection.',
      'Replying with concern is used to keep the conversation moving.',
    ],
    actions: [
      'Do not share credentials, PINs, or recovery information.',
      'Open the official banking app or call the number on your card yourself.',
      'If you clicked or responded, change credentials and contact the real bank immediately.',
    ],
    decisionOptions: [
      SmsDecisionOption(
        id: 'contact_known_channel',
        label: 'Call bank',
        description: 'Use the bank number you already trust.',
      ),
      SmsDecisionOption(
        id: 'report_block',
        label: 'Report',
        description: 'Report the message and block it.',
      ),
      SmsDecisionOption(
        id: 'share_code',
        label: 'Share code',
        description: 'Send the verification or banking code.',
      ),
      SmsDecisionOption(
        id: 'share_personal_info',
        label: 'Send details',
        description: 'Send DOB or other account details.',
      ),
    ],
  ),
  SmsThread(
    id: 'job_bait',
    contact: 'Part-Time Jobs UK',
    phoneNumber: '+44 7555 882301',
    preview:
        'Earn £300 a day from home with no interview. Training starts tonight if you join now.',
    kind: SmsKind.scam,
    scamType: 'Job bait / task scam',
    scenario: 'Too-good-to-be-true job offer',
    riskLevel: 'Medium-high risk',
    timeLabel: '14:42',
    messages: [
      SmsMessage(
        text:
            'Hello! We found your CV online. Earn £300/day from home rating products. No interview. Reply YES for instant onboarding.',
        timestamp: '14:39',
        incoming: true,
      ),
      SmsMessage(
        text:
            'We explain after registration. Limited places. Send your full name and WhatsApp number to secure your slot.',
        timestamp: '14:42',
        incoming: true,
      ),
    ],
    flags: [
      'Vague employer identity is a common warning sign in scam recruiting.',
      'Unrealistic pay and urgency are designed to override skepticism.',
      'The attacker avoids specifics and pushes you to move channels quickly.',
      'These scams often lead to fake task platforms, upfront fees, or identity harvesting.',
    ],
    actions: [
      'Avoid sharing personal details before you verify the employer independently.',
      'Search the company through trusted sources, not through the number that contacted you.',
      'Assume secrecy plus easy money is a red flag until proven otherwise.',
    ],
    decisionOptions: [
      SmsDecisionOption(
        id: 'ask_for_identity',
        label: 'Ask details',
        description: 'Challenge the sender for company details.',
      ),
      SmsDecisionOption(
        id: 'ignore_delete',
        label: 'Ignore',
        description: 'Ignore the job text.',
      ),
      SmsDecisionOption(
        id: 'reply_yes',
        label: 'Reply YES',
        description: 'Follow their onboarding instruction.',
      ),
      SmsDecisionOption(
        id: 'share_personal_info',
        label: 'Send details',
        description: 'Share your name and number.',
      ),
    ],
  ),
  SmsThread(
    id: 'friend_impersonation',
    contact: 'Friend? New Number',
    phoneNumber: '+44 7401 225901',
    preview:
        'Hey, this is me on a new number. Can you urgently help me buy a gift card?',
    kind: SmsKind.suspicious,
    scamType: 'Impersonation / urgency',
    scenario: 'Friend-in-need text',
    riskLevel: 'Medium-high risk',
    timeLabel: '20:11',
    messages: [
      SmsMessage(
        text:
            'Hey, it’s me. I lost access to my old phone. Save this new number. Are you free right now?',
        timestamp: '20:08',
        incoming: true,
      ),
      SmsMessage(
        text:
            'I’m in a meeting and can’t talk. Need a quick favor. Can you buy a £100 gift card and send me the code?',
        timestamp: '20:11',
        incoming: true,
      ),
    ],
    flags: [
      'The message tries to build urgency before proving identity.',
      'Refusing to speak on the phone is common when the attacker is impersonating someone.',
      'Gift card requests are a classic scam payment method because they are fast and irreversible.',
    ],
    actions: [
      'Verify through the real person’s old number or another channel you already trust.',
      'Do not send money, gift cards, or codes based only on text messages.',
      'Assume identity needs proof first, especially from a new number.',
    ],
    decisionOptions: [
      SmsDecisionOption(
        id: 'contact_known_channel',
        label: 'Verify friend',
        description: 'Call the real person using a trusted old number.',
      ),
      SmsDecisionOption(
        id: 'ask_for_identity',
        label: 'Ask who',
        description: 'Ask them to prove who they are.',
      ),
      SmsDecisionOption(
        id: 'buy_gift_card',
        label: 'Buy card',
        description: 'Send the requested gift card code.',
      ),
      SmsDecisionOption(
        id: 'reply_yes',
        label: 'Agree',
        description: 'Say yes and continue over text.',
      ),
    ],
  ),
];
