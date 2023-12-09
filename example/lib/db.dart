// ignore: file_names
class Db {
  static List<Hobby> hobbies = [
    const Hobby(
        id: '1.',
        name: 'Reading',
        detail:
            'Reading is a widely practiced hobby that has many benefits. It can help expand one\'s horizons and allows one to enjoy something new with every book that they read. One gets to learn about many things by reading books which can help look at life differently.'),
    const Hobby(
        id: '2.',
        name: 'Basketball',
        detail:
            'Basketball is an excellent idea for a hobby. It can be played anywhere like the house, gym, and school park. It is a great way to get one\'s mind off things and also a fantastic way of expressing oneself. It is a good pass time and also creates a bonding experience with friends and family.'),
    const Hobby(
        id: '3.',
        name: 'Golf',
        detail:
            'Golf is a great activity to explore, especially during the warm summer weather. It keeps the mind occupied, keeps one healthy, keeps one around people and out of the house. One can enjoy this game with not only friends and family but also get some time to themselves.'),
    const Hobby(
        id: '4.',
        name: 'Running',
        detail:
            'Running is one of the most versatile and beneficial hobbies. Exercise can help in having a healthy heart and increasing the lung and heart capacity. Running is a great way to give one\'s cardiovascular system a push. Running can also make a long-term healthy change to one\'s lifestyle.'),
    const Hobby(
        id: '5.',
        name: 'Walking',
        detail:
            'Research has shown that regular brisk walking can not only have physical benefits but also boost energy, improve mood and help reduce stress. It also helps prevent depression. Walking gives one the opportunity to breathe in the fresh air while spending time in nature.'),
    const Hobby(
        id: '6.',
        name: 'Soccer',
        detail:
            'Soccer is a popular sport that can be played by people of all ages. It is a great way to stay active and healthy while having fun. Soccer can also help develop teamwork and communication skills.'),
    const Hobby(
        id: '7.',
        name: 'Volleyball',
        detail:
            'Volleyball is a fun and exciting sport that can be played indoors or outdoors. It is a great way to stay active and healthy while having fun. Volleyball can also help develop teamwork and communication skills.'),
    const Hobby(
        id: '8.',
        name: 'Badminton',
        detail:
            'Badminton is a popular sport that can be played by people of all ages. It is a great way to stay active and healthy while having fun. Badminton can also help develop hand-eye coordination and reflexes.'),
    const Hobby(
        id: '9.',
        name: 'Yoga',
        detail:
            'Yoga is a great way to stay fit and healthy. It can help reduce stress, improve flexibility, and increase strength. Yoga can also help improve mental clarity and focus.'),
    const Hobby(
        id: '10.',
        name: 'Pilates',
        detail:
            'Pilates is a low-impact form of exercise that can help improve flexibility, strength, and balance. It can also help reduce stress and improve mental clarity.'),
    const Hobby(
        id: '11.',
        name: 'Swimming',
        detail:
            'Swimming is a great way to stay active and healthy. It is a low-impact form of exercise that can help improve cardiovascular health, muscle strength, and flexibility. Swimming can also help reduce stress and improve mental clarity.'),
    const Hobby(
        id: '12.',
        name: 'Ice skating',
        detail:
            'Ice skating is a fun and exciting activity that can be enjoyed by people of all ages. It is a great way to stay active and healthy while having fun. Ice skating can also help improve balance and coordination.'),
    const Hobby(
        id: '13.',
        name: 'Roller',
        detail:
            'skating Roller skating is a fun and exciting activity that can be enjoyed by people of all ages. It is a great way to stay active and healthy while having fun. Roller skating can also help improve balance and coordination.'),
    const Hobby(
        id: '14.',
        name: 'Rugby',
        detail:
            'Rugby is a popular sport that can be played by people of all ages. It is a great way to stay active and healthy while having fun. Rugby can also help develop teamwork and communication skills.'),
    const Hobby(
        id: '15.',
        name: 'Darts',
        detail:
            'Darts is a fun and exciting game that can be played by people of all ages. It is a great way to stay active and healthy while having fun. Darts can also help improve hand-eye coordination and concentration.'),
    const Hobby(
        id: '16.',
        name: 'Bowling',
        detail:
            'Bowling is a fun and exciting game that can be played by people of all ages. It is a great way to stay active and healthy while having fun. Bowling can also help improve hand-eye coordination and concentration.'),
    const Hobby(
        id: '17.',
        name: 'Ice hockey',
        detail:
            'Ice hockey is a fun and exciting sport that can be enjoyed by people of all ages. It is a great way to stay active and healthy while having fun. Ice hockey can also help improve balance and coordination.'),
    const Hobby(
        id: '18.',
        name: 'Surfing',
        detail:
            'Surfing is a fun and exciting activity that can be enjoyed by people of all ages. It is a great way to stay active and healthy while having fun. Surfing can also help improve balance and coordination.'),
    const Hobby(
        id: '19.',
        name: 'Tennis',
        detail:
            'Tennis is a popular sport that can be played by people of all ages. It is a great way to stay active and healthy while.'),
  ];
}

class Hobby {
  const Hobby({
    required this.id,
    required this.name,
    required this.detail,
  });

  final String id;
  final String name;
  final String detail;
}
