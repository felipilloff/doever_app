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
}
