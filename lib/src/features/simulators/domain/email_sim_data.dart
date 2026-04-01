import 'email_sim_models.dart';

const List<SimEmail> simEmails = [
  SimEmail(
    id: 'campus_it',
    scenarioType: EmailScenarioType.campusSafe,
    sender: 'Campus IT Support',
    fromAddress: 'support@cs310-university.edu',
    replyTo: 'support@cs310-university.edu',
    toAddress: 'student@uni.edu',
    subject: 'Scheduled Password Reset Reminder',
    preview:
        'This is your normal semester reminder to review your password and MFA settings.',
    body:
        'Hello,\n\nAs part of our routine semester security review, please check that your account recovery email and MFA settings are up to date.\n\nDo not use links from unexpected messages. Instead, open the student portal directly from your usual bookmark.\n\nRegards,\nCampus IT Support',
    kind: EmailKind.safe,
    technique: 'Legit security notice',
    theme: 'Routine account hygiene',
    riskLevel: 'Low risk',
    flags: [
      'The domain matches the institution and the reply-to also matches.',
      'There is no panic language, threat, or unrealistic deadline.',
      'The message tells you to go to the portal directly instead of pushing a shortcut link.',
      'The wording is consistent and does not ask for passwords or codes.',
    ],
    actions: [
      'You can still verify it in the normal portal if you want.',
      'Use your saved bookmark rather than any email link.',
      'Treat even real emails as prompts, not as login pathways.',
    ],
    decisionOptions: [
      EmailDecisionOption(
        id: 'open_real_site',
        label: 'Open portal',
        description: 'Open the usual portal from your own bookmark.',
      ),
      EmailDecisionOption(
        id: 'ignore',
        label: 'Ignore',
        description: 'Leave the email alone for now.',
      ),
      EmailDecisionOption(
        id: 'reply_question',
        label: 'Reply',
        description: 'Reply with a short acknowledgment.',
      ),
    ],
  ),
  SimEmail(
    id: 'microsoft_phish',
    scenarioType: EmailScenarioType.accountPhishing,
    sender: 'Microsoft Account Team',
    fromAddress: 'security-alert@micr0softverify-login.com',
    replyTo: 'resetforms@micr0softverify-login.com',
    toAddress: 'student@uni.edu',
    subject: 'URGENT: Your Microsoft 365 mailbox will be disabled today',
    preview:
        'Your account has triggered abnormal activity. Verify immediately to avoid permanent shutdown.',
    body:
        'Dear User,\n\nWe detected malicious sign in activity from Russia and your Microsoft 365 mailbox will be disabled in 45 minutes unless you verify ownership.\n\nClick below immediately:\nhttps://microsoft-check-session-security.com/recover\n\nFailure to comply will result in message deletion and access suspension.\n\nMicrosoft Account Security Team',
    kind: EmailKind.phishing,
    technique: 'Credential harvesting',
    theme: 'Urgent account warning',
    riskLevel: 'High risk',
    flags: [
      'The sender domain is not Microsoft and uses a lookalike spelling.',
      'The message creates urgency, fear, and a fake countdown.',
      'Generic greeting like “Dear User” is common in mass phishing.',
      'The link domain does not match the brand being claimed.',
    ],
    actions: [
      'Do not click the link or enter credentials.',
      'Open the real Microsoft account page manually if you want to confirm.',
      'Report and delete the email.',
    ],
    decisionOptions: [
      EmailDecisionOption(
        id: 'open_real_site',
        label: 'Verify separately',
        description: 'Open the real Microsoft page yourself.',
      ),
      EmailDecisionOption(
        id: 'report_delete',
        label: 'Report',
        description: 'Report it and remove it from the inbox.',
      ),
      EmailDecisionOption(
        id: 'click_link',
        label: 'Open link',
        description: 'Follow the link in the email.',
      ),
      EmailDecisionOption(
        id: 'send_credentials',
        label: 'Send login',
        description: 'Submit account credentials to verify.',
      ),
    ],
  ),
  SimEmail(
    id: 'payroll_scam',
    scenarioType: EmailScenarioType.payrollScam,
    sender: 'HR Payroll Office',
    fromAddress: 'payroll@company-payroll-help.net',
    replyTo: 'forms@company-payroll-help.net',
    toAddress: 'employee@company.com',
    subject: 'Updated direct deposit form required before payroll close',
    preview: 'Please submit your banking details by 3 PM to avoid salary hold.',
    body:
        'Hi,\n\nWe are migrating salary processing. Every staff member must complete the attached bank verification form today before 3 PM. Employees who fail to respond may see delayed wages.\n\nOpen Attachment: Payroll_Update_Form.html\n\nPayroll Desk',
    kind: EmailKind.scam,
    technique: 'Fake payroll update / attachment lure',
    theme: 'Sensitive data theft',
    riskLevel: 'High risk',
    flags: [
      'It asks for banking information under deadline pressure.',
      'The sender domain is not the organization domain.',
      'An HTML attachment can open a fake sign-in or data collection page.',
      'Threatening salary delay is a classic pressure tactic.',
    ],
    actions: [
      'Verify with payroll using the known phone number or company chat.',
      'Do not open the attachment.',
      'Report it internally as a payroll phishing attempt.',
    ],
    decisionOptions: [
      EmailDecisionOption(
        id: 'call_known_contact',
        label: 'Verify payroll',
        description: 'Contact payroll through known company channels.',
      ),
      EmailDecisionOption(
        id: 'report_internal',
        label: 'Report',
        description: 'Report it as internal phishing.',
      ),
      EmailDecisionOption(
        id: 'open_attachment',
        label: 'Open attachment',
        description: 'Open the attached form.',
      ),
      EmailDecisionOption(
        id: 'send_bank_info',
        label: 'Send bank info',
        description: 'Complete the requested form with banking details.',
      ),
    ],
  ),
  SimEmail(
    id: 'parcel_fee',
    scenarioType: EmailScenarioType.parcelFee,
    sender: 'Delivery Notifications',
    fromAddress: 'tracking@parcel-redelivery-center.com',
    replyTo: 'tracking@parcel-redelivery-center.com',
    toAddress: 'student@uni.edu',
    subject: 'Package delivery failed - small redelivery fee required',
    preview:
        'A £1.79 fee is needed to release your parcel. Update details now.',
    body:
        'Customer,\n\nYour package could not be delivered due to missing address validation. To schedule redelivery, pay the small processing fee below.\n\nPay Fee Now\n\nIf you do not confirm today, your package will be returned.\n\nParcel Dispatch Team',
    kind: EmailKind.scam,
    technique: 'Micro-payment bait',
    theme: 'Fake parcel redelivery',
    riskLevel: 'Medium to high risk',
    flags: [
      'Unexpected package alerts are often used to lure card details.',
      'The sender is vague and not linked to a known delivery provider.',
      'A tiny fee is meant to feel harmless while capturing card data.',
      'No shipment reference or official order context is provided.',
    ],
    actions: [
      'Check your real order history in the retailer or courier app.',
      'Never pay through the email shortcut.',
      'Delete or report the message if no shipment is expected.',
    ],
    decisionOptions: [
      EmailDecisionOption(
        id: 'verify_official',
        label: 'Check courier',
        description: 'Use the real courier or retailer account.',
      ),
      EmailDecisionOption(
        id: 'report_delete',
        label: 'Report',
        description: 'Report the email and remove it.',
      ),
      EmailDecisionOption(
        id: 'click_link',
        label: 'Open link',
        description: 'Follow the redelivery link.',
      ),
      EmailDecisionOption(
        id: 'send_bank_info',
        label: 'Pay fee',
        description: 'Enter card details to release the parcel.',
      ),
    ],
  ),
  SimEmail(
    id: 'ceo_giftcards',
    scenarioType: EmailScenarioType.ceoImpersonation,
    sender: 'CEO Office',
    fromAddress: 'ceo.office@corp-executive-mail.com',
    replyTo: 'ceo.office@corp-executive-mail.com',
    toAddress: 'assistant@company.com',
    subject: 'Need 6 gift cards for client appreciation before 2 PM',
    preview:
        'I am in meetings. Buy them now and send the codes by reply email.',
    body:
        'Hi,\n\nI am tied up in back-to-back meetings and need six gift cards for a client appreciation package. Buy them now and email me the codes before 2 PM. I will reimburse you later.\n\nPlease keep this between us so we can handle it quickly.\n\nCEO',
    kind: EmailKind.scam,
    technique: 'Executive impersonation / BEC',
    theme: 'Gift card fraud',
    riskLevel: 'High risk',
    flags: [
      'Gift card requests plus secrecy are a major business email compromise sign.',
      'The sender domain is not the corporate domain.',
      'Attackers often impersonate executives to bypass normal approval processes.',
      '“Keep this between us” is meant to stop verification.',
    ],
    actions: [
      'Verify any unusual request with the executive using a known contact method.',
      'Never send gift card codes or financial details only by email instruction.',
      'Escalate it internally as an impersonation attempt.',
    ],
    decisionOptions: [
      EmailDecisionOption(
        id: 'call_known_contact',
        label: 'Verify request',
        description: 'Use a trusted contact path to verify the CEO request.',
      ),
      EmailDecisionOption(
        id: 'report_internal',
        label: 'Escalate',
        description: 'Report the impersonation attempt internally.',
      ),
      EmailDecisionOption(
        id: 'buy_gift_cards',
        label: 'Buy cards',
        description: 'Purchase and send the gift card codes.',
      ),
      EmailDecisionOption(
        id: 'reply_question',
        label: 'Reply only',
        description: 'Reply in the same thread asking a question.',
      ),
    ],
  ),
];
