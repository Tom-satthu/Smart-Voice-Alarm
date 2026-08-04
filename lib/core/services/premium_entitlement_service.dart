import '../../shared/data/local_store.dart';
import '../constants/app_constants.dart';

/// Local premium entitlement gate used across alarm creation flows.
class PremiumEntitlementService {
  PremiumEntitlementService([SettingsRepository? repo])
    : _repo = repo ?? SettingsRepository();

  final SettingsRepository _repo;

  bool get isPremium => _repo.loadPremiumUnlocked();

  int get freeAlarmLimit => AppConstants.freeAlarmLimit;

  bool canCreateAlarm(int currentCount) {
    if (isPremium) return true;
    return currentCount < freeAlarmLimit;
  }

  bool canDuplicateAlarm(int currentCount) => canCreateAlarm(currentCount);

  Future<void> setPremiumUnlocked(bool unlocked) =>
      _repo.savePremiumUnlocked(unlocked);
}
