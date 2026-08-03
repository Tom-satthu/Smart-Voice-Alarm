import 'package:flutter/material.dart';

enum AlarmType { voice, ringtone, mixed }

enum VoiceSegmentType { recording, tts }

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// UI prototype model — no persistence layer in Phase 1.
class AlarmUiModel {
  const AlarmUiModel({
    required this.id,
    required this.time,
    required this.repeatDays,
    required this.isEnabled,
    required this.type,
    required this.label,
    this.voiceSequenceId,
    this.ringtoneName,
    this.repeatCount = 3,
  });

  final String id;
  final TimeOfDay time;
  final Set<Weekday> repeatDays;
  final bool isEnabled;
  final AlarmType type;
  final String label;
  final String? voiceSequenceId;
  final String? ringtoneName;
  final int repeatCount;

  AlarmUiModel copyWith({
    String? id,
    TimeOfDay? time,
    Set<Weekday>? repeatDays,
    bool? isEnabled,
    AlarmType? type,
    String? label,
    String? voiceSequenceId,
    String? ringtoneName,
    int? repeatCount,
  }) {
    return AlarmUiModel(
      id: id ?? this.id,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      type: type ?? this.type,
      label: label ?? this.label,
      voiceSequenceId: voiceSequenceId ?? this.voiceSequenceId,
      ringtoneName: ringtoneName ?? this.ringtoneName,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }
}

class VoiceSegmentUiModel {
  const VoiceSegmentUiModel({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    this.text,
  });

  final String id;
  final String name;
  final VoiceSegmentType type;
  final Duration duration;
  final String? text;

  VoiceSegmentUiModel copyWith({
    String? id,
    String? name,
    VoiceSegmentType? type,
    Duration? duration,
    String? text,
  }) {
    return VoiceSegmentUiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      text: text ?? this.text,
    );
  }
}

class VoiceSequenceUiModel {
  const VoiceSequenceUiModel({
    required this.id,
    required this.name,
    required this.segments,
  });

  final String id;
  final String name;
  final List<VoiceSegmentUiModel> segments;

  VoiceSequenceUiModel copyWith({
    String? id,
    String? name,
    List<VoiceSegmentUiModel>? segments,
  }) {
    return VoiceSequenceUiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      segments: segments ?? this.segments,
    );
  }
}

class TtsVoiceUiModel {
  const TtsVoiceUiModel({
    required this.id,
    required this.name,
    required this.locale,
    required this.isPremium,
  });

  final String id;
  final String name;
  final String locale;
  final bool isPremium;
}

class RingtoneUiModel {
  const RingtoneUiModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
