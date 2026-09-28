import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/soundscape.dart';

String soundLabel(AppLocalizations s, FocusSound sound) => switch (sound) {
  FocusSound.white => s.focusWhite,
  FocusSound.pink => s.focusPink,
  FocusSound.brown => s.focusBrown,
  FocusSound.grey => s.focusGrey,
  FocusSound.lightRain => s.focusLightRain,
  FocusSound.heavyRain => s.focusHeavyRain,
  FocusSound.thunder => s.focusThunder,
  FocusSound.wind => s.focusWind,
  FocusSound.ocean => s.focusOcean,
  FocusSound.stream => s.focusStream,
  FocusSound.birds => s.focusBirds,
  FocusSound.crickets => s.focusCrickets,
  FocusSound.fireplace => s.focusFireplace,
  FocusSound.vinyl => s.focusVinyl,
  FocusSound.cafe => s.focusCafe,
  FocusSound.train => s.focusTrain,
  FocusSound.keyboard => s.focusKeyboard,
  FocusSound.office => s.focusOffice,
};
String categoryLabel(AppLocalizations s, SoundCategory category) =>
    switch (category) {
      SoundCategory.noise => s.focusNoise,
      SoundCategory.weather => s.focusWeather,
      SoundCategory.nature => s.focusNature,
      SoundCategory.cozy => s.focusCozy,
      SoundCategory.urban => s.focusUrban,
      SoundCategory.workspace => s.focusWorkspace,
    };
String mixLabel(AppLocalizations s, Soundscape mix) => !mix.isBuiltIn
    ? mix.name
    : switch (mix.id) {
        'preset:deep' => s.focusDeepPreset,
        'preset:cafe' => s.focusCafePreset,
        'preset:night' => s.focusNightPreset,
        'preset:forest' => s.focusForestPreset,
        'preset:storm' => s.focusStormPreset,
        'preset:journey' => s.focusJourneyPreset,
        'preset:draft' => s.focusNew,
        _ => mix.name,
      };
IconData soundIcon(FocusSound sound) => switch (sound) {
  FocusSound.white ||
  FocusSound.pink ||
  FocusSound.brown ||
  FocusSound.grey => Icons.graphic_eq,
  FocusSound.lightRain || FocusSound.heavyRain => Icons.water_drop_outlined,
  FocusSound.thunder => Icons.thunderstorm_outlined,
  FocusSound.wind => Icons.air,
  FocusSound.ocean => Icons.waves,
  FocusSound.stream => Icons.water,
  FocusSound.birds => Icons.forest_outlined,
  FocusSound.crickets => Icons.nightlight_outlined,
  FocusSound.fireplace => Icons.local_fire_department_outlined,
  FocusSound.vinyl => Icons.album_outlined,
  FocusSound.cafe => Icons.local_cafe_outlined,
  FocusSound.train => Icons.train_outlined,
  FocusSound.keyboard => Icons.keyboard_outlined,
  FocusSound.office => Icons.desk_outlined,
};
