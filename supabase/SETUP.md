# Подключение Supabase Auth

Локальная версия приложения использует проект DreamWorld. Секретный ключ `service_role` в клиентское приложение не добавлять.

Перед реальной отправкой писем:

1. В Supabase Dashboard откройте **Authentication → URL Configuration** и добавьте в **Redirect URLs**:
   - `https://maksimepifanov.github.io/DreamWorld/#/auth/callback`
   - `https://maksimepifanov.github.io/DreamWorld/#/reset-password`
   - `dreamworld://auth-callback`
   - `dreamworld://auth-callback/reset-password`
2. В разделе **Authentication → SMTP Settings** подключите SMTP-провайдера. Пока SMTP не настроен, письма могут не отправляться либо действуют жёсткие ограничения тестовой доставки Supabase.
3. Проверьте шаблоны **Confirm signup** и **Reset password**. Их ссылки должны использовать шаблон Supabase `{{ .ConfirmationURL }}`.
4. Выполните миграцию `migrations/202611120001_user_profiles.sql` в SQL Editor проекта. Она создаёт профиль при создании пользователя и включает политики RLS.
5. В **Authentication → Providers → Email** оставьте включённым подтверждение email.
6. После добавления URL запустите приложение на сайте и Android, проверьте регистрацию и восстановление пароля тестовым адресом.

Пароли хранятся и проверяются Supabase Auth. `public.profiles` не содержит пароль и доступна пользователю только для чтения/изменения собственной строки.
