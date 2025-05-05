# mini_social_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Further action plan:
1. Создать таблицу `users` в Firestore. При регистрации — сохранять туда uid, displayName, email и photoUrl.
2. Загружать комментарии с привязкой к `uid` и отображать `displayName` из таблицы `users`.
3. После регистрации/авторизации — перенаправлять пользователя на `HomeScreen`.
4. Если пользователь не авторизован — скрывать UI-элементы: поле ввода комментария, кнопку создания поста и т.п.
5. После создания поста — делать навигацию на экран `PostDetailScreen`.
6. Настроить кэширование комментариев (например, через провайдер или SharedPreferences).
7. Добавить поддержку реплаев на комментарии (через `parentCommentId`).
8. Настроить глобальное состояние пользователя через `UserProvider`, чтобы не обращаться постоянно к `FirebaseAuth.instance`.
9. Настроить дизайн (аватарки, стили, отступы, темы).