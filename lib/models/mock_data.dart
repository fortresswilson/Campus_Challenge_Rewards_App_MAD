// lib/models/mock_data.dart
// Shared mock data for demo - Person 2 will replace with real SQLite calls

class MockUser {
  final String id;
  final String name;
  final String email;
  final int totalPoints;
  final int challengesJoined;
  final int challengesCompleted;
  final int currentStreak;
  final List<String> badges;

  MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.totalPoints,
    required this.challengesJoined,
    required this.challengesCompleted,
    required this.currentStreak,
    required this.badges,
  });
}

class MockChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int pointsReward;
  final String duration;
  final int durationDays;
  final String difficulty;
  final int participantCount;
  final double progress;
  final bool isJoined;
  final String emoji;

  MockChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pointsReward,
    required this.duration,
    required this.durationDays,
    required this.difficulty,
    required this.participantCount,
    required this.progress,
    required this.isJoined,
    required this.emoji,
  });
}

// Mock current user (will be replaced by SharedPreferences/SQLite)
final MockUser currentUser = MockUser(
  id: '1',
  name: 'Alex Johnson',
  email: 'alex@gsu.edu',
  totalPoints: 340,
  challengesJoined: 5,
  challengesCompleted: 3,
  currentStreak: 7,
  badges: ['First Challenge', '100 Points', '3 Completed'],
);

// Mock challenge list (will be replaced by SQLite)
List<MockChallenge> mockChallenges = [
  MockChallenge(
    id: '1',
    title: '10K Steps Daily',
    description: 'Walk 10,000 steps every day for a week. Great for staying active on campus!',
    category: 'Fitness',
    pointsReward: 150,
    duration: '7 days',
    durationDays: 7,
    difficulty: 'Medium',
    participantCount: 42,
    progress: 0.6,
    isJoined: true,
    emoji: '🚶',
  ),
  MockChallenge(
    id: '2',
    title: 'No Social Media',
    description: 'Stay off social media for 3 days and see how your focus improves.',
    category: 'Mindfulness',
    pointsReward: 100,
    duration: '3 days',
    durationDays: 3,
    difficulty: 'Hard',
    participantCount: 28,
    progress: 0.0,
    isJoined: false,
    emoji: '🧘',
  ),
  MockChallenge(
    id: '3',
    title: 'Study Streak',
    description: 'Study for at least 2 hours every day for 5 days straight.',
    category: 'Academic',
    pointsReward: 200,
    duration: '5 days',
    durationDays: 5,
    difficulty: 'Medium',
    participantCount: 67,
    progress: 0.4,
    isJoined: true,
    emoji: '📚',
  ),
  MockChallenge(
    id: '4',
    title: 'Hydration Hero',
    description: 'Drink 8 glasses of water every day for a week. Track it each day!',
    category: 'Health',
    pointsReward: 80,
    duration: '7 days',
    durationDays: 7,
    difficulty: 'Easy',
    participantCount: 91,
    progress: 0.0,
    isJoined: false,
    emoji: '💧',
  ),
  MockChallenge(
    id: '5',
    title: 'Morning Run',
    description: 'Run for 20 minutes before 8 AM every day for 5 days.',
    category: 'Fitness',
    pointsReward: 175,
    duration: '5 days',
    durationDays: 5,
    difficulty: 'Hard',
    participantCount: 19,
    progress: 0.0,
    isJoined: false,
    emoji: '🏃',
  ),
  MockChallenge(
    id: '6',
    title: 'Read 30 mins',
    description: 'Read a non-textbook book for 30 minutes every day this week.',
    category: 'Academic',
    pointsReward: 120,
    duration: '7 days',
    durationDays: 7,
    difficulty: 'Easy',
    participantCount: 54,
    progress: 0.0,
    isJoined: false,
    emoji: '📖',
  ),
];

final List<Map<String, dynamic>> leaderboard = [
  {'name': 'Jordan K.', 'points': 890, 'avatar': '🦁'},
  {'name': 'Sam T.', 'points': 740, 'avatar': '🐯'},
  {'name': 'Alex J.', 'points': 340, 'avatar': '🦊'},
  {'name': 'Riley M.', 'points': 290, 'avatar': '🐺'},
  {'name': 'Casey L.', 'points': 210, 'avatar': '🦅'},
];