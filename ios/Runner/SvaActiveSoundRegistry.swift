import Foundation

/// Pins CAF files still referenced by unsolved occurrences / live AlarmKit mappings.
/// Cleanup must never delete these while an occurrence is unsolved or recovery is active.
enum SvaActiveSoundRegistry {
  static func pinnedFileNames() -> Set<String> {
    var names = Set<String>()
    names.insert(SvaSilenceAudio.defaultFileName)

    for state in SvaOccurrenceStore.loadAll() where !state.solved {
      for clip in state.cycleTemplate where !clip.soundFileName.isEmpty {
        names.insert(clip.soundFileName)
      }
    }

    for mapping in SvaAlarmKitStore.load() where !mapping.soundFileName.isEmpty {
      let parent = mapping.parentAlarmId
      let occurrence = mapping.occurrenceId
      if SvaOccurrenceStore.isSolved(parent: parent, occurrence: occurrence) {
        continue
      }
      names.insert(mapping.soundFileName)
    }

    return names
  }

  static func isPinned(_ fileName: String) -> Bool {
    guard !fileName.isEmpty else { return false }
    return pinnedFileNames().contains(fileName)
  }
}
