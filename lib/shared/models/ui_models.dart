import 'package:flutter/material.dart';

enum AlarmType { voice, ringtone, mixed }

enum VoiceSegmentType { recording, tts }

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': time.hour,
        'minute': time.minute,
        'repeatDays': repeatDays.map((d) => d.name).toList(),
        'isEnabled': isEnabled,
        'type': type.name,
        'label': label,
        'voiceSequenceId': voiceSequenceId,
        'ringtoneName': ringtoneName,
        'repeatCount': repeatCount,
      };

  factory AlarmUiModel.fromJson(Map<String, dynamic> json) {
    final days = <Weekday>{};
    for (final raw in (json['repeatDays'] as List<dynamic>? ?? const [])) {
      days.add(Weekday.values.byName(raw as String));
    }
    return AlarmUiModel(
      id: json['id'] as String,
      time: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      repeatDays: days,
      isEnabled: json['isEnabled'] as bool? ?? true,
      type: AlarmType.values.byName(json['type'] as String? ?? 'voice'),
      label: json['label'] as String? ?? 'Alarm',
      voiceSequenceId: json['voiceSequenceId'] as String?,
      ringtoneName: json['ringtoneName'] as String?,
      repeatCount: json['repeatCount'] as int? ?? 3,
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
    this.filePath,
    this.voiceId,
    this.localeId,
  });

  final String id;
  final String name;
  final VoiceSegmentType type;
  final Duration duration;
  final String? text;
  final String? filePath;
  final String? voiceId;
  final String? localeId;

  VoiceSegmentUiModel copyWith({
    String? id,
    String? name,
    VoiceSegmentType? type,
    Duration? duration,
    String? text,
    String? filePath,
    String? voiceId,
    String? localeId,
  }) {
    return VoiceSegmentUiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      filePath: filePath ?? this.filePath,
      voiceId: voiceId ?? this.voiceId,
      localeId: localeId ?? this.localeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'durationMs': duration.inMilliseconds,
        'text': text,
        'filePath': filePath,
        'voiceId': voiceId,
        'localeId': localeId,
      };

  factory VoiceSegmentUiModel.fromJson(Map<String, dynamic> json) {
    return VoiceSegmentUiModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Segment',
      type: VoiceSegmentType.values.byName(
        json['type'] as String? ?? 'recording',
      ),
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      text: json['text'] as String?,
      filePath: json['filePath'] as String?,
      voiceId: json['voiceId'] as String?,
      localeId: json['localeId'] as String?,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'segments': segments.map((s) => s.toJson()).toList(),
      };

  factory VoiceSequenceUiModel.fromJson(Map<String, dynamic> json) {
    final rawSegments = json['segments'] as List<dynamic>? ?? const [];
    return VoiceSequenceUiModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Sequence',
      segments: rawSegments
          .map((e) => VoiceSegmentUiModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }
}

class TtsVoiceUiModel {
  const TtsVoiceUiModel({
    required this.id,
    required this.name,
    required this.locale,
    this.isPremium = false,
    this.quality = TtsVoiceQuality.defaultQuality,
    this.availability = TtsVoiceAvailability.installedOffline,
    this.isUsable = true,
  });

  final String id;
  final String name;
  final String locale;
  final bool isPremium;
  final TtsVoiceQuality quality;
  final TtsVoiceAvailability availability;
  final bool isUsable;
}

enum TtsVoiceQuality { defaultQuality, enhanced, premium }

enum TtsVoiceAvailability {
  installedOffline,
  networkRequired,
  notInstalled,
}

class RingtoneUiModel {
  const RingtoneUiModel({
    required this.id,
    required this.name,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String assetPath;
}
