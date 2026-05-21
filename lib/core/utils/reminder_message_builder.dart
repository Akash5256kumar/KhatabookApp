/// Shared helper for building the default WhatsApp reminder copy.
String buildReminderMessage({
  required String customerName,
  required String formattedAmount,
}) {
  return 'Namaste $customerName ji, '
      'Aapka $formattedAmount pending hai. '
      'Kripya jaldi payment kar dijiye. '
      'Dhanyavaad.';
}
