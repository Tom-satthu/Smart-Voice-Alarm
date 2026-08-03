import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ui_models.dart';

/// In-memory UI prototype state. No database or business logic in Phase 1.
class AlarmListController extends StateNotifier<List<AlarmUiModel>> {
  AlarmListController() : super(_seedAlarms);

  static final List<AlarmUiModel> _seedAlarms = [
    const AlarmUiModel(
      id: 'alarm-1',
      time: TimeOfDay(hour: 6, minute: 30),
      repeatDays: {
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      },
      isEnabled: true,
      type: AlarmType.voice,
      label: 'Morning focus',
      voiceSequenceId: 'seq-1',
      ringtoneName: 'Soft Chime',
      repeatCount: 3,
    ),
    const AlarmUiModel(
      id: 'alarm-2',
      time: TimeOfDay(hour: 7, minute: 15),
      repeatDays: {Weekday.saturday, Weekday.sunday},
      isEnabled: true,
      type: AlarmType.mixed,
      label: 'Weekend rise',
      voiceSequenceId: 'seq-1',
      ringtoneName: 'Ocean Breeze',
      repeatCount: 2,
    ),
    const AlarmUiModel(
      id: 'alarm-3',
      time: TimeOfDay(hour: 22, minute: 0),
      repeatDays: {},
      isEnabled: false,
      type: AlarmType.ringtone,
      label: 'Wind down',
      ringtoneName: 'Night Pulse',
      repeatCount: 1,
    ),
  ];

  void toggle(String id) {
    state = [
      for (final alarm in state)
        if (alarm.id == id)
          alarm.copyWith(isEnabled: !alarm.isEnabled)
        else
          alarm,
    ];
  }

  void remove(String id) {
    state = state.where((alarm) => alarm.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  void restoreSeed() {
    state = List<AlarmUiModel>.from(_seedAlarms);
  }
}

final alarmListProvider =
    StateNotifierProvider<AlarmListController, List<AlarmUiModel>>((ref) {
  return AlarmListController();
});

class VoiceSequenceController
    extends StateNotifier<VoiceSequenceUiModel> {
  VoiceSequenceController()
      : super(
          const VoiceSequenceUiModel(
            id: 'seq-1',
            name: 'Morning motivation',
            segments: [
              VoiceSegmentUiModel(
                id: 'seg-1',
                name: 'Wake gently',
                type: VoiceSegmentType.recording,
                duration: Duration(seconds: 8),
              ),
              VoiceSegmentUiModel(
                id: 'seg-2',
                name: 'Today matters',
                type: VoiceSegmentType.tts,
                duration: Duration(seconds: 12),
                text: 'Today is a great day. Stand up and breathe.',
              ),
              VoiceSegmentUiModel(
                id: 'seg-3',
                name: 'Hydrate reminder',
                type: VoiceSegmentType.recording,
                duration: Duration(seconds: 5),
              ),
            ],
          ),
        );

  void reorder(int oldIndex, int newIndex) {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = segments.removeAt(oldIndex);
    segments.insert(newIndex, item);
    state = state.copyWith(segments: segments);
  }

  void removeAt(int index) {
    final segments = List<VoiceSegmentUiModel>.from(state.segments)
      ..removeAt(index);
    state = state.copyWith(segments: segments);
  }

  void add(VoiceSegmentUiModel segment) {
    state = state.copyWith(segments: [...state.segments, segment]);
  }
}

final voiceSequenceProvider =
    StateNotifierProvider<VoiceSequenceController, VoiceSequenceUiModel>((ref) {
  return VoiceSequenceController();
});

final ttsVoicesProvider = Provider<List<TtsVoiceUiModel>>((ref) {
  return const [
    TtsVoiceUiModel(
      id: 'voice-1',
      name: 'Ava',
      locale: 'en-US',
      isPremium: false,
    ),
    TtsVoiceUiModel(
      id: 'voice-2',
      name: 'Noah',
      locale: 'en-US',
      isPremium: false,
    ),
    TtsVoiceUiModel(
      id: 'voice-3',
      name: 'Sophia',
      locale: 'en-GB',
      isPremium: true,
    ),
    TtsVoiceUiModel(
      id: 'voice-4',
      name: 'Liam',
      locale: 'en-AU',
      isPremium: true,
    ),
  ];
});

final ringtonesProvider = Provider<List<RingtoneUiModel>>((ref) {
  return const [
    RingtoneUiModel(id: 'ring-1', name: 'Soft Chime'),
    RingtoneUiModel(id: 'ring-2', name: 'Ocean Breeze'),
    RingtoneUiModel(id: 'ring-3', name: 'Night Pulse'),
    RingtoneUiModel(id: 'ring-4', name: 'Forest Dawn'),
    RingtoneUiModel(id: 'ring-5', name: 'Crystal Bell'),
  ];
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  void setLocale(Locale locale) => state = locale;
}

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class ReminderSettings extends StateNotifier<bool> {
  ReminderSettings() : super(true);

  void setEnabled(bool value) => state = value;
}

final reminderEnabledProvider =
    StateNotifierProvider<ReminderSettings, bool>((ref) {
  return ReminderSettings();
});
