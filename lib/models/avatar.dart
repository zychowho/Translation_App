class Avatar {
  final String id;
  final String assetPath;
  final String displayName;

  Avatar({
    required this.id,
    required this.assetPath,
    required this.displayName,
  });
}

// List of all 10 available avatars
final List<Avatar> avatarOptions = [
  Avatar(
      id: 'avatar1',
      assetPath: 'assets/avatars/avatar1.png',
      displayName: 'Avatar 1'),
  Avatar(
      id: 'avatar2',
      assetPath: 'assets/avatars/avatar2.png',
      displayName: 'Avatar 2'),
  Avatar(
      id: 'avatar3',
      assetPath: 'assets/avatars/avatar3.png',
      displayName: 'Avatar 3'),
  Avatar(
      id: 'avatar4',
      assetPath: 'assets/avatars/avatar4.png',
      displayName: 'Avatar 4'),
  Avatar(
      id: 'avatar5',
      assetPath: 'assets/avatars/avatar5.png',
      displayName: 'Avatar 5'),
  Avatar(
      id: 'avatar6',
      assetPath: 'assets/avatars/avatar6.png',
      displayName: 'Avatar 6'),
  Avatar(
      id: 'avatar7',
      assetPath: 'assets/avatars/avatar7.png',
      displayName: 'Avatar 7'),
  Avatar(
      id: 'avatar8',
      assetPath: 'assets/avatars/avatar8.png',
      displayName: 'Avatar 8'),
  Avatar(
      id: 'avatar9',
      assetPath: 'assets/avatars/avatar9.png',
      displayName: 'Avatar 9'),
  Avatar(
      id: 'avatar10',
      assetPath: 'assets/avatars/avatar10.png',
      displayName: 'Avatar 10'),
];
