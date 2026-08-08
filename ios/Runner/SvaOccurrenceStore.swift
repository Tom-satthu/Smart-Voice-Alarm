import Foundation

/// One audible/silence clip in the repeating cycle template (no TTS/recording text).
struct SvaCycleClip: Codable, Equatable {
  var role: String
  var soundFileName: String
  var durationMs: Int
  var label: String

  var asDictionary: [String: Any] {
    [
      "role": role,
      "soundFileName": soundFileName,
      "durationMs": durationMs,
      "label": label,
    ]
  }

  static func from(dictionary: [String: Any]) -> SvaCycleClip? {
    guard let role = dictionary["role"] as? String,
          let file = dictionary["soundFileName"] as? String
    else { return nil }
    let duration: Int
    if let n = dictionary["durationMs"] as? NSNumber {
      duration = n.intValue
    } else if let i = dictionary["durationMs"] as? Int {
      duration = i
    } else {
      duration = 0
    }
    return SvaCycleClip(
      role: role,
      soundFileName: file,
      durationMs: duration,
      label: (dictionary["label"] as? String) ?? role
    )
  }
}

/// Persisted AlarmKit occurrence lifecycle (solved vs rolling unsolved).
struct SvaOccurrenceState: Codable, Equatable {
  var parentAlarmId: String
  var occurrenceId: String
  var solved: Bool
  var revision: String
  var rollingHorizonEnd: Double
  var cyclesScheduled: Int
  var childCount: Int
  var audibleChildCount: Int
  var silentChildCount: Int
  var cycleDurationMs: Int
  var updatedAt: Double
  var recoveryGeneration: Int
  var cancellationGeneration: Int
  var lastStoppedAlarmKitId: String
  var recoveryScheduledAt: Double
  var recoveryAlarmKitId: String
  var recoveryReason: String
  /// Trailing silence baked into audible CAF (not planner padding).
  var trailingSilenceMs: Int
  var gapMs: Int
  var alarmTitle: String
  var cycleTemplate: [SvaCycleClip]
  /// When false, Stop is a valid dismiss (no Math Challenge / recovery).
  var mathChallengeEnabled: Bool
  /// Empty repeatDays at schedule time — parent should disable after complete.
  var isOneShot: Bool

  init(
    parentAlarmId: String,
    occurrenceId: String,
    solved: Bool,
    revision: String,
    rollingHorizonEnd: Double,
    cyclesScheduled: Int,
    childCount: Int,
    audibleChildCount: Int,
    silentChildCount: Int,
    cycleDurationMs: Int,
    updatedAt: Double,
    recoveryGeneration: Int = 0,
    cancellationGeneration: Int = 0,
    lastStoppedAlarmKitId: String = "",
    recoveryScheduledAt: Double = 0,
    recoveryAlarmKitId: String = "",
    recoveryReason: String = "",
    trailingSilenceMs: Int = 1250,
    gapMs: Int = 5000,
    alarmTitle: String = "Smart Voice Alarm",
    cycleTemplate: [SvaCycleClip] = [],
    mathChallengeEnabled: Bool = true,
    isOneShot: Bool = false
  ) {
    self.parentAlarmId = parentAlarmId
    self.occurrenceId = occurrenceId
    self.solved = solved
    self.revision = revision
    self.rollingHorizonEnd = rollingHorizonEnd
    self.cyclesScheduled = cyclesScheduled
    self.childCount = childCount
    self.audibleChildCount = audibleChildCount
    self.silentChildCount = silentChildCount
    self.cycleDurationMs = cycleDurationMs
    self.updatedAt = updatedAt
    self.recoveryGeneration = recoveryGeneration
    self.cancellationGeneration = cancellationGeneration
    self.lastStoppedAlarmKitId = lastStoppedAlarmKitId
    self.recoveryScheduledAt = recoveryScheduledAt
    self.recoveryAlarmKitId = recoveryAlarmKitId
    self.recoveryReason = recoveryReason
    self.trailingSilenceMs = trailingSilenceMs
    self.gapMs = gapMs
    self.alarmTitle = alarmTitle
    self.cycleTemplate = cycleTemplate
    self.mathChallengeEnabled = mathChallengeEnabled
    self.isOneShot = isOneShot
  }

  var asDictionary: [String: Any] {
    [
      "parentAlarmId": parentAlarmId,
      "occurrenceId": occurrenceId,
      "solved": solved,
      "occurrenceSolved": solved,
      "revision": revision,
      "rollingHorizonEnd": rollingHorizonEnd,
      "cyclesScheduled": cyclesScheduled,
      "childCount": childCount,
      "audibleChildCount": audibleChildCount,
      "silentChildCount": silentChildCount,
      "cycleDurationMs": cycleDurationMs,
      "updatedAt": updatedAt,
      "recoveryGeneration": recoveryGeneration,
      "cancellationGeneration": cancellationGeneration,
      "lastStoppedAlarmKitId": lastStoppedAlarmKitId,
      "recoveryScheduledAt": recoveryScheduledAt,
      "recoveryAlarmKitId": recoveryAlarmKitId,
      "recoveryReason": recoveryReason,
      "trailingSilenceMs": trailingSilenceMs,
      "gapMs": gapMs,
      "alarmTitle": alarmTitle,
      "cycleTemplateCount": cycleTemplate.count,
      "mathChallengeEnabled": mathChallengeEnabled,
      "isOneShot": isOneShot,
    ]
  }

  enum CodingKeys: String, CodingKey {
    case parentAlarmId, occurrenceId, solved, revision, rollingHorizonEnd
    case cyclesScheduled, childCount, audibleChildCount, silentChildCount
    case cycleDurationMs, updatedAt, recoveryGeneration, cancellationGeneration
    case lastStoppedAlarmKitId, recoveryScheduledAt, recoveryAlarmKitId
    case recoveryReason, trailingSilenceMs, transitionPaddingMs, gapMs, alarmTitle, cycleTemplate
    case mathChallengeEnabled, isOneShot
  }

  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    parentAlarmId = try c.decode(String.self, forKey: .parentAlarmId)
    occurrenceId = try c.decode(String.self, forKey: .occurrenceId)
    solved = try c.decode(Bool.self, forKey: .solved)
    revision = try c.decodeIfPresent(String.self, forKey: .revision) ?? ""
    rollingHorizonEnd = try c.decodeIfPresent(Double.self, forKey: .rollingHorizonEnd) ?? 0
    cyclesScheduled = try c.decodeIfPresent(Int.self, forKey: .cyclesScheduled) ?? 0
    childCount = try c.decodeIfPresent(Int.self, forKey: .childCount) ?? 0
    audibleChildCount = try c.decodeIfPresent(Int.self, forKey: .audibleChildCount) ?? 0
    silentChildCount = try c.decodeIfPresent(Int.self, forKey: .silentChildCount) ?? 0
    cycleDurationMs = try c.decodeIfPresent(Int.self, forKey: .cycleDurationMs) ?? 0
    updatedAt = try c.decodeIfPresent(Double.self, forKey: .updatedAt) ?? 0
    recoveryGeneration = try c.decodeIfPresent(Int.self, forKey: .recoveryGeneration) ?? 0
    cancellationGeneration = try c.decodeIfPresent(Int.self, forKey: .cancellationGeneration) ?? 0
    lastStoppedAlarmKitId = try c.decodeIfPresent(String.self, forKey: .lastStoppedAlarmKitId) ?? ""
    recoveryScheduledAt = try c.decodeIfPresent(Double.self, forKey: .recoveryScheduledAt) ?? 0
    recoveryAlarmKitId = try c.decodeIfPresent(String.self, forKey: .recoveryAlarmKitId) ?? ""
    recoveryReason = try c.decodeIfPresent(String.self, forKey: .recoveryReason) ?? ""
    if let trail = try c.decodeIfPresent(Int.self, forKey: .trailingSilenceMs) {
      trailingSilenceMs = trail
    } else {
      // Legacy R6 field — do not treat as planner padding anymore.
      trailingSilenceMs = try c.decodeIfPresent(Int.self, forKey: .transitionPaddingMs) ?? 1250
    }
    gapMs = try c.decodeIfPresent(Int.self, forKey: .gapMs) ?? 5000
    alarmTitle = try c.decodeIfPresent(String.self, forKey: .alarmTitle) ?? "Smart Voice Alarm"
    cycleTemplate = try c.decodeIfPresent([SvaCycleClip].self, forKey: .cycleTemplate) ?? []
    mathChallengeEnabled = try c.decodeIfPresent(Bool.self, forKey: .mathChallengeEnabled) ?? true
    isOneShot = try c.decodeIfPresent(Bool.self, forKey: .isOneShot) ?? false
  }

  func encode(to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: CodingKeys.self)
    try c.encode(parentAlarmId, forKey: .parentAlarmId)
    try c.encode(occurrenceId, forKey: .occurrenceId)
    try c.encode(solved, forKey: .solved)
    try c.encode(revision, forKey: .revision)
    try c.encode(rollingHorizonEnd, forKey: .rollingHorizonEnd)
    try c.encode(cyclesScheduled, forKey: .cyclesScheduled)
    try c.encode(childCount, forKey: .childCount)
    try c.encode(audibleChildCount, forKey: .audibleChildCount)
    try c.encode(silentChildCount, forKey: .silentChildCount)
    try c.encode(cycleDurationMs, forKey: .cycleDurationMs)
    try c.encode(updatedAt, forKey: .updatedAt)
    try c.encode(recoveryGeneration, forKey: .recoveryGeneration)
    try c.encode(cancellationGeneration, forKey: .cancellationGeneration)
    try c.encode(lastStoppedAlarmKitId, forKey: .lastStoppedAlarmKitId)
    try c.encode(recoveryScheduledAt, forKey: .recoveryScheduledAt)
    try c.encode(recoveryAlarmKitId, forKey: .recoveryAlarmKitId)
    try c.encode(recoveryReason, forKey: .recoveryReason)
    try c.encode(trailingSilenceMs, forKey: .trailingSilenceMs)
    try c.encode(gapMs, forKey: .gapMs)
    try c.encode(alarmTitle, forKey: .alarmTitle)
    try c.encode(cycleTemplate, forKey: .cycleTemplate)
    try c.encode(mathChallengeEnabled, forKey: .mathChallengeEnabled)
    try c.encode(isOneShot, forKey: .isOneShot)
  }

  static func empty(parent: String, occurrence: String) -> SvaOccurrenceState {
    SvaOccurrenceState(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      solved: false,
      revision: "",
      rollingHorizonEnd: 0,
      cyclesScheduled: 0,
      childCount: 0,
      audibleChildCount: 0,
      silentChildCount: 0,
      cycleDurationMs: 0,
      updatedAt: Date().timeIntervalSince1970,
      recoveryGeneration: 0,
      cancellationGeneration: 0,
      lastStoppedAlarmKitId: "",
      recoveryScheduledAt: 0,
      recoveryAlarmKitId: "",
      recoveryReason: "",
      trailingSilenceMs: 1250,
      gapMs: 5000,
      alarmTitle: "Smart Voice Alarm",
      cycleTemplate: [],
      mathChallengeEnabled: true,
      isOneShot: false
    )
  }
}

enum SvaOccurrenceStore {
  private static let key = "sva_alarmkit_occurrence_states"
  private static var defaults: UserDefaults { .standard }

  private static func mapKey(parent: String, occurrence: String) -> String {
    "\(parent)|\(occurrence)"
  }

  static func loadAll() -> [SvaOccurrenceState] {
    guard let data = defaults.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([SvaOccurrenceState].self, from: data)) ?? []
  }

  static func saveAll(_ items: [SvaOccurrenceState]) {
    if let data = try? JSONEncoder().encode(items) {
      defaults.set(data, forKey: key)
    }
  }

  static func upsert(_ state: SvaOccurrenceState) {
    var all = Dictionary(uniqueKeysWithValues: loadAll().map {
      (mapKey(parent: $0.parentAlarmId, occurrence: $0.occurrenceId), $0)
    })
    all[mapKey(parent: state.parentAlarmId, occurrence: state.occurrenceId)] = state
    saveAll(Array(all.values))
  }

  static func get(parent: String, occurrence: String) -> SvaOccurrenceState? {
    loadAll().first {
      $0.parentAlarmId == parent && $0.occurrenceId == occurrence
    }
  }

  static func isSolved(parent: String, occurrence: String) -> Bool {
    get(parent: parent, occurrence: occurrence)?.solved == true
  }

  static func markSolved(parent: String, occurrence: String) {
    var state = get(parent: parent, occurrence: occurrence)
      ?? SvaOccurrenceState.empty(parent: parent, occurrence: occurrence)
    state.solved = true
    state.cancellationGeneration += 1
    state.updatedAt = Date().timeIntervalSince1970
    upsert(state)
    NSLog(
      "[SVA-AlarmKit] occurrence solved parent=%@ occurrence=%@ cancelGen=%d",
      parent,
      occurrence,
      state.cancellationGeneration
    )
  }

  static func remove(parent: String, occurrence: String) {
    saveAll(loadAll().filter {
      !($0.parentAlarmId == parent && $0.occurrenceId == occurrence)
    })
  }
}
