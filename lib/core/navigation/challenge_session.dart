/// Tracks open Math Challenge occurrences to prevent duplicates.
final Set<String> openChallengeKeys = {};

String challengeKey(String parentId, String occurrenceId) =>
    '$parentId|$occurrenceId';

void clearChallengeKey(String parentId, String occurrenceId) {
  openChallengeKeys.remove(challengeKey(parentId, occurrenceId));
}

bool markChallengeOpen(String parentId, String occurrenceId) {
  final key = challengeKey(parentId, occurrenceId);
  if (openChallengeKeys.contains(key)) return false;
  openChallengeKeys.add(key);
  return true;
}
