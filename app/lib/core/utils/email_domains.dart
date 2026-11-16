/// Почтовые домены Mail.ru Group, которые часто отбрасывают письма Firebase.
bool isMailRuEmail(String email) {
  final int at = email.indexOf('@');
  if (at < 0) return false;
  final String domain = email.substring(at + 1).trim().toLowerCase();
  return const <String>{
    'mail.ru',
    'inbox.ru',
    'list.ru',
    'bk.ru',
    'internet.ru',
    'mail.ua',
  }.any((String value) => domain == value || domain.endsWith('.$value'));
}
