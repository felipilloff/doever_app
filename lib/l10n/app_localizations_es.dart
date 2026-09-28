// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Doever';

  @override
  String get tagline => 'Haz lo que importa.';

  @override
  String get myDay => 'Mi día';

  @override
  String get important => 'Importante';

  @override
  String get planned => 'Programadas';

  @override
  String get tasks => 'Tareas';

  @override
  String get lists => 'Tus listas';

  @override
  String get newList => 'Nueva lista';

  @override
  String get renameList => 'Cambiar nombre de la lista';

  @override
  String get deleteList => 'Eliminar lista';

  @override
  String get deleteListMessage =>
      'Las tareas de esta lista se moverán a Tareas.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get delete => 'Eliminar';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get settings => 'Configuración';

  @override
  String get search => 'Buscar tareas';

  @override
  String get searchHint => 'Buscar en títulos y notas';

  @override
  String get addTask => 'Agregar tarea';

  @override
  String get taskTitle => 'Título de la tarea';

  @override
  String get addStep => 'Agregar paso';

  @override
  String get renameStep => 'Cambiar nombre del paso';

  @override
  String get notes => 'Notas';

  @override
  String get notesHint => 'Agrega una nota…';

  @override
  String get dueDate => 'Fecha de vencimiento';

  @override
  String get reminder => 'Recordatorio';

  @override
  String get repeat => 'Repetir';

  @override
  String get never => 'Nunca';

  @override
  String get daily => 'Todos los días';

  @override
  String get weekdays => 'Días laborables';

  @override
  String get weekly => 'Cada semana';

  @override
  String get monthly => 'Cada mes';

  @override
  String get yearly => 'Cada año';

  @override
  String get moveTo => 'Mover a una lista';

  @override
  String get removeDate => 'Quitar fecha de vencimiento';

  @override
  String get removeReminder => 'Quitar recordatorio';

  @override
  String get addToMyDay => 'Agregar a Mi día';

  @override
  String get removeFromMyDay => 'Quitar de Mi día';

  @override
  String get markImportant => 'Marcar como importante';

  @override
  String get unmarkImportant => 'Quitar importancia';

  @override
  String get completeTask => 'Completar tarea';

  @override
  String get uncompleteTask => 'Reabrir tarea';

  @override
  String get completeStep => 'Completar paso';

  @override
  String get uncompleteStep => 'Reabrir paso';

  @override
  String get deleteStep => 'Eliminar paso';

  @override
  String get deleteTask => 'Eliminar tarea';

  @override
  String get taskDeleted => 'Tarea eliminada';

  @override
  String get undo => 'Deshacer';

  @override
  String get closeDetails => 'Cerrar detalles';

  @override
  String get taskDetails => 'Detalles de la tarea';

  @override
  String get emptyDay => 'No hay nada programado para hoy.';

  @override
  String get emptyDayHint => 'Agrega una tarea abajo o tráela de otra lista.';

  @override
  String get emptyImportant => 'No hay tareas importantes.';

  @override
  String get emptyImportantHint =>
      'Marca una tarea con una estrella para tenerla a mano.';

  @override
  String get emptyPlanned => 'No hay tareas programadas.';

  @override
  String get emptyPlannedHint =>
      'Aquí aparecerán las tareas con fecha de vencimiento.';

  @override
  String get emptyTasks => 'Un espacio para comenzar.';

  @override
  String get emptyTasksHint => 'Agrega tu primera tarea abajo.';

  @override
  String get emptySearch => 'No se encontraron tareas.';

  @override
  String get emptySearchHint =>
      'Prueba con otro título o una palabra de tus notas.';

  @override
  String get theme => 'Apariencia';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get showCompleted => 'Mostrar tareas completadas';

  @override
  String get preferences => 'Preferencias';

  @override
  String get privacyTitle => 'Local por diseño';

  @override
  String get privacyBody =>
      'Tus tareas permanecen en este dispositivo. Sin cuenta, análisis, publicidad ni seguimiento.';

  @override
  String get validationError =>
      'Revisa los datos e inténtalo de nuevo. Los títulos no pueden estar vacíos y los recordatorios deben ser futuros.';

  @override
  String get persistenceError =>
      'No se pudieron guardar los cambios. Revisa el espacio disponible e inténtalo de nuevo.';

  @override
  String get notificationError =>
      'Los recordatorios no están disponibles o se denegó el permiso de notificaciones. Revisa la configuración del sistema.';

  @override
  String get unexpectedError => 'Ocurrió un problema. Inténtalo de nuevo.';

  @override
  String get loadError =>
      'No se pudieron cargar tus tareas. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get reminderPending =>
      'No se pudo aplicar un cambio en el recordatorio. Doever lo intentará de nuevo automáticamente.';

  @override
  String get remindersUnsupported =>
      'Esta plataforma no admite recordatorios programados.';

  @override
  String get moveUp => 'Subir';

  @override
  String get moveDown => 'Bajar';

  @override
  String get reorder => 'Reordenar';

  @override
  String get openNavigation => 'Abrir navegación';

  @override
  String get quickAddHint => 'Nueva tarea: Ctrl/Cmd+N';

  @override
  String get searchShortcutHint => 'Buscar: Ctrl/Cmd+F';

  @override
  String get completed => 'Completada';

  @override
  String get taskUnavailable => 'Esta tarea ya no está disponible.';

  @override
  String get startupError =>
      'Doever no pudo abrir el almacenamiento local. Revisa el espacio disponible y vuelve a intentarlo.';

  @override
  String get saving => 'Guardando…';

  @override
  String get saved => 'Guardado en este dispositivo';

  @override
  String get reminderTiming =>
      'Android puede retrasar los recordatorios para ahorrar batería.';

  @override
  String get recurrenceHint =>
      'La próxima tarea se crea al completar esta. Los recordatorios se configuran por separado para cada tarea.';

  @override
  String get steps => 'Pasos';

  @override
  String get back => 'Atrás';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get today => 'Hoy';

  @override
  String get allLocal => 'Guardado en este dispositivo';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String dueOn(String date) {
    return 'Vence el $date';
  }

  @override
  String remindOn(String date) {
    return 'Recordarme el $date';
  }

  @override
  String get titleRequired => 'Ingresa un título para la tarea.';

  @override
  String get language => 'Idioma';

  @override
  String get backgroundTitle => 'Fondo del área de trabajo';

  @override
  String get backgroundDescription =>
      'Haz tuyo este espacio. Elige una imagen que te ayude a concentrarte.';

  @override
  String get backgroundPreview => 'Vista previa de tu área de trabajo';

  @override
  String get backgroundApplying => 'Preparando tu fondo…';

  @override
  String get backgroundChoose => 'Elegir imagen';

  @override
  String get backgroundChange => 'Cambiar imagen';

  @override
  String get backgroundRemove => 'Quitar fondo';

  @override
  String get backgroundLoadError =>
      'No se pudo abrir la imagen guardada. Elige otra imagen o quita el fondo.';

  @override
  String get backgroundFormats =>
      'PNG, JPEG o WebP · Hasta 20 MB. Las imágenes horizontales se adaptan mejor.';

  @override
  String get backgroundLocal =>
      'Guardado en este dispositivo. Tu imagen original se conserva intacta.';

  @override
  String get backgroundInvalid =>
      'Elige una imagen PNG, JPEG o WebP válida, sin animación (hasta 20 MB y 40 megapíxeles).';

  @override
  String get notesLabel => 'Notas';

  @override
  String get newPage => 'Nueva página';

  @override
  String get untitledPage => 'Sin título';

  @override
  String get noNotes => 'Todavía no hay notas. Crea una página para comenzar.';

  @override
  String get searchPages => 'Buscar páginas';

  @override
  String get searchPage => 'Buscar en la página';

  @override
  String get noteSaved => 'Guardado localmente';

  @override
  String get noteSaving => 'Guardando…';

  @override
  String get noteSaveFailed => 'Cambios sin guardar. Reintenta antes de salir.';

  @override
  String get noteHint => 'Escribe algo o usa / para insertar bloques';

  @override
  String get blockActions => 'Acciones del bloque';

  @override
  String get addBlock => 'Añadir bloque';

  @override
  String get duplicateBlock => 'Duplicar';

  @override
  String get changeBlock => 'Cambiar tipo de bloque';

  @override
  String get blockDeleted => 'Bloque eliminado';

  @override
  String get pageDeleted => 'Página eliminada';

  @override
  String get createNoteTask => 'Crear tarea de Doever';

  @override
  String get noteTaskCreated => 'Tarea creada en Tareas';

  @override
  String get noteRedo => 'Rehacer';

  @override
  String get previousMatch => 'Resultado anterior';

  @override
  String get nextMatch => 'Resultado siguiente';

  @override
  String get noteUrl => 'Dirección web (http o https)';

  @override
  String get noteInvalidUrl => 'Introduce una dirección http o https válida.';

  @override
  String get noteOpenLink => 'Abrir enlace';

  @override
  String get noteImage => 'Elegir imagen';

  @override
  String get noteImageError => 'Imagen no disponible';

  @override
  String get noteToggleBody => 'Contenido desplegable';

  @override
  String get noteIcon => 'Icono del aviso (opcional)';

  @override
  String get noteText => 'Texto';

  @override
  String get noteH1 => 'Encabezado 1';

  @override
  String get noteH2 => 'Encabezado 2';

  @override
  String get noteH3 => 'Encabezado 3';

  @override
  String get noteBullet => 'Lista con viñetas';

  @override
  String get noteNumbered => 'Lista numerada';

  @override
  String get noteTodo => 'Pendiente';

  @override
  String get noteQuote => 'Cita';

  @override
  String get noteDivider => 'Separador';

  @override
  String get noteCode => 'Código';

  @override
  String get noteCallout => 'Aviso';

  @override
  String get noteLink => 'Enlace';

  @override
  String get noteToggle => 'Desplegable';

  @override
  String get noteChoosePage => 'Selecciona una página o crea una nueva.';

  @override
  String get themeStudio => 'Estudio de temas';

  @override
  String get themeStudioSubtitle => 'Dale tu estilo a Doever';

  @override
  String get themeLayers => 'Base, Superficie y Acento';

  @override
  String get themeFoundation => 'Base';

  @override
  String get themeSurface => 'Superficie';

  @override
  String get themeAccent => 'Acento';

  @override
  String get themeFoundationDescription =>
      'El fondo del espacio de trabajo y su ambiente general.';

  @override
  String get themeSurfaceDescription =>
      'Tarjetas, paneles, campos y contenido elevado.';

  @override
  String get themeAccentDescription =>
      'Acciones, foco, selección y personalidad.';

  @override
  String get themeApply => 'Aplicar';

  @override
  String get themeUnsaved => 'Cambios del tema sin guardar';

  @override
  String get themeLeavePrompt =>
      '¿Aplicar los cambios antes de salir del estudio de temas?';

  @override
  String get themeContinueEditing => 'Seguir editando';

  @override
  String get themeDiscard => 'Descartar';

  @override
  String get themeNameInvalid =>
      'Escribe un nombre de entre 1 y 200 caracteres.';

  @override
  String get themeApplied => 'Tema aplicado';

  @override
  String get themeApplyFailed =>
      'No se pudo aplicar el tema. Tus cambios se conservan.';

  @override
  String get themeUntitled => 'Tema sin título';

  @override
  String get themeRename => 'Renombrar tema';

  @override
  String themeDeleteTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get themeDeleteMessage =>
      'Este tema guardado se eliminará permanentemente.';

  @override
  String get themeFile => 'Tema de Doever';

  @override
  String get themeFileTooLarge =>
      'El archivo es demasiado grande. Elige uno de menos de 64 KB.';

  @override
  String get themeFileInvalid => 'El archivo no es un tema de Doever válido.';

  @override
  String get themeExportFailed => 'No se pudo exportar el tema.';

  @override
  String get themeSaveFailed =>
      'No se pudo guardar el cambio. Inténtalo de nuevo.';

  @override
  String get themeBack => 'Volver a configuración';

  @override
  String get themeRedo => 'Rehacer';

  @override
  String get themeThemes => 'Temas';

  @override
  String get themeLivePreview => 'Vista previa en vivo';

  @override
  String get themePreviewHint =>
      'Previsualiza los cambios en Doever antes de aplicarlos';

  @override
  String get themePreviewInApp => 'Previsualizar en la app';

  @override
  String get themeContrastGood => 'Contraste · Bueno';

  @override
  String get themeContrastProtected => 'Contraste · Legibilidad protegida';

  @override
  String get themeName => 'Nombre del tema';

  @override
  String get themeReset => 'Restablecer tema';

  @override
  String get themeMode => 'Modo';

  @override
  String get themeAutoBalance => 'Equilibrio automático';

  @override
  String get themeAutoBalanceDescription =>
      'Mantén las capas diferenciadas y fáciles de leer.';

  @override
  String get themeLowContrast => 'Contraste bajo en los colores elegidos';

  @override
  String get themeBalanceContrast => 'Equilibrar contraste automáticamente';

  @override
  String get themeBalanced => 'Equilibrado automáticamente';

  @override
  String get themeFix => 'Corregir automáticamente';

  @override
  String get themeKeep => 'Mantener de todos modos';

  @override
  String get themeGallery => 'Galería de temas';

  @override
  String get themeImport => 'Importar tema';

  @override
  String get themeExport => 'Exportar tema';

  @override
  String get themeGalleryDescription =>
      'Parte de un diseño predefinido o de uno guardado.';

  @override
  String get themeBuiltIn => 'Predefinidos';

  @override
  String get themeSaved => 'Guardados';

  @override
  String get themeNew => 'Nuevo tema';

  @override
  String get themeEmpty => 'Tus temas guardados aparecerán aquí.';

  @override
  String get themeActive => 'Aplicado';

  @override
  String themeActions(String name) {
    return 'Acciones de $name';
  }

  @override
  String get themeResetLayer => 'Restablecer capa';

  @override
  String get themeSolid => 'Sólido';

  @override
  String get themeGradient => 'Degradado';

  @override
  String get themeColors => 'Colores';

  @override
  String get themeAddStop => 'Añadir color';

  @override
  String get themeRemoveStop => 'Quitar color';

  @override
  String themeColorStop(int number) {
    return 'Color $number';
  }

  @override
  String get themeDirection => 'Dirección';

  @override
  String get themeTopBottom => 'De arriba abajo';

  @override
  String get themeBottomTop => 'De abajo arriba';

  @override
  String get themeLeftRight => 'De izquierda a derecha';

  @override
  String get themeRightLeft => 'De derecha a izquierda';

  @override
  String get themeTopLeftBottomRight => 'De arriba izquierda a abajo derecha';

  @override
  String get themeTopRightBottomLeft => 'De arriba derecha a abajo izquierda';

  @override
  String get themeBottomLeftTopRight => 'De abajo izquierda a arriba derecha';

  @override
  String get themeBottomRightTopLeft => 'De abajo derecha a arriba izquierda';

  @override
  String get themeAdvanced => 'Avanzado';

  @override
  String get themeAdvancedDescription =>
      'Tono, intensidad y fuerza del degradado';

  @override
  String get themeTone => 'Tono';

  @override
  String get themeIntensity => 'Intensidad';

  @override
  String get themeGradientStrength => 'Fuerza del degradado';

  @override
  String themePercent(String label, int value) {
    return '$label: $value por ciento';
  }

  @override
  String get themeHexInvalid => 'Usa #RRGGBB';

  @override
  String get themeSaturationBrightness => 'Saturación y brillo';

  @override
  String get themeHue => 'Matiz';

  @override
  String themeHueDegrees(int value) {
    return 'Matiz: $value grados';
  }

  @override
  String get themeRecentColors => 'Colores recientes';

  @override
  String get themePreviewSemantics =>
      'Vista previa del tema: navegación, tareas, texto, campo y acción';

  @override
  String get themePersonalSpace => 'Tu espacio personal';

  @override
  String get themeRoom => 'Espacio para lo que importa.';

  @override
  String get themeSampleDone => 'Organiza tu día';

  @override
  String get themeSampleTask => 'Revisar notas del proyecto';

  @override
  String get themeLocal => 'Todos los cambios quedan en tu equipo';

  @override
  String get themeCreate => 'Crear';

  @override
  String get themeHierarchyBalanced =>
      'Se equilibraron Base y Superficie para distinguir mejor las capas.';

  @override
  String get themeHierarchyLow =>
      'Base y Superficie se distinguen poco entre sí.';

  @override
  String get themeAccentAdjusted =>
      'Se ajustó el acento para mantener el texto legible.';

  @override
  String get themeGradientMissing =>
      'Un degradado necesita al menos dos colores.';

  @override
  String get themeLightAdjusted =>
      'Se ajustaron los tonos para que el modo claro sea legible.';

  @override
  String get themeDarkAdjusted =>
      'Se ajustaron los tonos para que el modo oscuro sea legible.';

  @override
  String themeCopyName(String name) {
    return '$name (copia)';
  }

  @override
  String get themePresetMidnight => 'Medianoche';

  @override
  String get themePresetGraphite => 'Grafito';

  @override
  String get themePresetOcean => 'Océano';

  @override
  String get themePresetAurora => 'Aurora';

  @override
  String get themePresetEmber => 'Brasa';

  @override
  String get themePresetForest => 'Bosque';

  @override
  String get themePresetSand => 'Arena';

  @override
  String get focusLabel => 'Concentración';

  @override
  String get focusTagline => 'Un espacio para concentrarte.';

  @override
  String get focusLocal => 'Ambientes sintéticos originales. Sin conexión.';

  @override
  String get focusMixer => 'Tu mezcla';

  @override
  String get focusLibrary => 'Biblioteca de sonidos';

  @override
  String get focusPresets => 'Para cada momento';

  @override
  String get focusCustom => 'Tus ambientes';

  @override
  String get focusNew => 'Nuevo ambiente';

  @override
  String get focusSave => 'Guardar ambiente';

  @override
  String get focusCopy => 'Guardar una copia';

  @override
  String get focusDelete => '¿Eliminar este ambiente?';

  @override
  String get focusPlay => 'Reproducir';

  @override
  String get focusPause => 'Pausar';

  @override
  String get focusStop => 'Detener';

  @override
  String get focusMute => 'Silenciar';

  @override
  String get focusUnmute => 'Activar sonido';

  @override
  String get focusMaster => 'Volumen general';

  @override
  String get focusDynamic => 'Ambiente dinámico';

  @override
  String get focusDynamicHint => 'Variaciones lentas y sutiles del volumen.';

  @override
  String get focusAdd => 'Añadir sonido';

  @override
  String get focusRemove => 'Quitar sonido';

  @override
  String get focusLimit => 'Hasta ocho sonidos por mezcla.';

  @override
  String get focusEmpty => 'Elige un ambiente o crea el tuyo.';

  @override
  String get focusAddHint => 'Añade un sonido de la biblioteca para empezar.';

  @override
  String get focusUnsaved => 'Mezcla editada · guárdala en tu biblioteca';

  @override
  String get focusAudioError =>
      'No se pudo iniciar o actualizar el audio. Intenta reproducir otra vez.';

  @override
  String get focusStorageError =>
      'No se pudieron guardar los cambios. Reintenta antes de cerrar.';

  @override
  String get focusNoise => 'Ruido';

  @override
  String get focusWeather => 'Clima';

  @override
  String get focusNature => 'Naturaleza';

  @override
  String get focusCozy => 'Acogedor';

  @override
  String get focusUrban => 'Urbano';

  @override
  String get focusWorkspace => 'Espacio de trabajo';

  @override
  String get focusWhite => 'Ruido blanco';

  @override
  String get focusPink => 'Ruido rosa';

  @override
  String get focusBrown => 'Ruido marrón';

  @override
  String get focusGrey => 'Ruido gris';

  @override
  String get focusLightRain => 'Lluvia suave';

  @override
  String get focusHeavyRain => 'Lluvia intensa';

  @override
  String get focusThunder => 'Truenos lejanos';

  @override
  String get focusWind => 'Viento';

  @override
  String get focusOcean => 'Olas del mar';

  @override
  String get focusStream => 'Arroyo';

  @override
  String get focusBirds => 'Canto de aves';

  @override
  String get focusCrickets => 'Grillos nocturnos';

  @override
  String get focusFireplace => 'Chimenea';

  @override
  String get focusVinyl => 'Crujido de vinilo';

  @override
  String get focusCafe => 'Ambiente de cafetería';

  @override
  String get focusTrain => 'Viaje en tren';

  @override
  String get focusKeyboard => 'Teclado suave';

  @override
  String get focusOffice => 'Oficina tranquila';

  @override
  String get focusDeepPreset => 'Concentración profunda';

  @override
  String get focusCafePreset => 'Cafetería bajo la lluvia';

  @override
  String get focusNightPreset => 'Código nocturno';

  @override
  String get focusForestPreset => 'Estudio en el bosque';

  @override
  String get focusStormPreset => 'Tarde de tormenta';

  @override
  String get focusJourneyPreset => 'Viaje tranquilo';

  @override
  String get focusLoadError =>
      'No se pudo cargar Concentración. Inténtalo de nuevo.';
}
