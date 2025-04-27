import '../models/post.dart';

List<Post> testPosts = [
  Post(
    title: 'Матч 1: Команда A против Команды B',
    description: 'Обсуждаем матч между этими командами. Как думаете, кто победит?',
    date: DateTime.now(),
    comments: [
      Comment(username: 'User1', text: 'Думаю, выиграет команда A!'),
      Comment(username: 'User2', text: 'Не согласен, команда B сильнее'),
    ],
  ),
  Post(
    title: 'Турнир 2: Чемпионат мира по футболу',
    description: 'Как вам шансы команд на чемпионате? Обсуждаем турнир!',
    date: DateTime.now().subtract(Duration(days: 1)),
    comments: [
      Comment(username: 'User3', text: 'Турнир обещает быть интересным!'),
    ],
  ),
];
