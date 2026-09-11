import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var screenProtectionChannel: FlutterMethodChannel?
  private var nativeAlarmChannel: FlutterMethodChannel?
  private var isScreenProtectionEnabled = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configurar UNUserNotificationCenterDelegate para manejar notificaciones
    UNUserNotificationCenter.current().delegate = self
    
    // Configurar canal de método para prevención de grabación
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    screenProtectionChannel = FlutterMethodChannel(
      name: "screen_recording_prevention",
      binaryMessenger: controller.binaryMessenger
    )
    
    screenProtectionChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      switch call.method {
      case "enableScreenProtection":
        self.enableScreenProtection()
        result(true)
      case "disableScreenProtection":
        self.disableScreenProtection()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Configurar canal para programar alarmas nativas (iOS)
    nativeAlarmChannel = FlutterMethodChannel(
      name: "native_alarm_scheduler",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Configurar canal para rastreo de registros
    let recordTrackerChannel = FlutterMethodChannel(
      name: "notification_record_tracker",
      binaryMessenger: controller.binaryMessenger
    )
    
    recordTrackerChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "markSleepRecordSaved":
        let prefs = UserDefaults.standard
        prefs.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: "last_sleep_record_time")
        result(true)
      case "markLactationRecordSaved":
        let prefs = UserDefaults.standard
        prefs.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: "last_lactation_record_time")
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    nativeAlarmChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      switch call.method {
      case "scheduleSleepNotification":
        if let timestamp = call.arguments as? [String: Any],
           let timestampValue = timestamp["timestamp"] as? Int64 {
          self.scheduleNativeNotification(timestamp: timestampValue) { success in
            result(success)
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Timestamp is required", details: nil))
        }
      case "cancelSleepNotification":
        self.cancelNativeNotification { success in
          result(success)
        }
      case "scheduleLactationNotification":
        if let args = call.arguments as? [String: Any],
           let timestamp = args["timestamp"] as? Int64,
           let notificationId = args["notification_id"] as? Int,
           let title = args["title"] as? String,
           let body = args["body"] as? String {
          self.scheduleLactationNotification(
            timestamp: timestamp,
            notificationId: notificationId,
            title: title,
            body: body
          ) { success in
            result(success)
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
        }
      case "cancelLactationNotification":
        if let args = call.arguments as? [String: Any],
           let notificationId = args["notification_id"] as? Int {
          self.cancelLactationNotification(notificationId: notificationId) { success in
            result(success)
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Notification ID is required", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Solicitar permisos de notificación
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("✅ iOS: Permisos de notificación concedidos")
      } else {
        print("❌ iOS: Permisos de notificación denegados")
      }
    }
    
    // Observar cambios en el estado de captura de pantalla
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @objc private func screenCaptureDidChange() {
    // Detectar si se está grabando la pantalla
    let isCaptured = UIScreen.main.isCaptured
    
    if isCaptured && isScreenProtectionEnabled {
      // Notificar a Flutter que se detectó grabación
      screenProtectionChannel?.invokeMethod("onScreenRecordingDetected", arguments: true)
      
      // Mostrar advertencia o pausar el video
      DispatchQueue.main.async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
          let alert = UIAlertController(
            title: "Grabación de pantalla detectada",
            message: "La grabación de pantalla no está permitida durante la reproducción de videos.",
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          rootViewController.present(alert, animated: true)
        }
      }
    }
  }
  
  private func enableScreenProtection() {
    isScreenProtectionEnabled = true
    
    // En iOS, no podemos prevenir completamente la grabación de pantalla,
    // pero podemos detectarla y reaccionar
    // También podemos intentar ocultar contenido sensible
    if UIScreen.main.isCaptured {
      screenCaptureDidChange()
    }
  }
  
  private func disableScreenProtection() {
    isScreenProtectionEnabled = false
  }
  
  // MARK: - Native Notification Scheduling (iOS)
  
  private func scheduleNativeNotification(timestamp: Int64, completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    
    // Convertir timestamp a Date
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    
    // Guardar timestamp de la notificación para verificar si se registró
    let prefs = UserDefaults.standard
    prefs.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: "last_sleep_notification_time")
    
    // Crear contenido de la notificación
    let content = UNMutableNotificationContent()
    content.title = "🌙 Registro de Sueño Diario"
    content.body = "¿Cuántas horas durmió el bebé anoche?"
    content.sound = .default
    content.categoryIdentifier = "SLEEP_REMINDER"
    content.userInfo = ["type": "daily_sleep_registration"]
    
    // Crear trigger basado en fecha/hora específica
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // Crear request con ID único
    let request = UNNotificationRequest(
      identifier: "sleep_notification_889",
      content: content,
      trigger: trigger
    )
    
    // Programar la notificación
    center.add(request) { [weak self] error in
      if let error = error {
        print("❌ iOS: Error programando notificación nativa: \(error.localizedDescription)")
        completion(false)
      } else {
        print("✅ iOS: Notificación nativa programada para \(dateComponents)")
        // Programar notificación de reenvío para 30 minutos después
        self?.scheduleSleepReminderNotification(originalTime: date)
        completion(true)
      }
    }
  }
  
  private func scheduleSleepReminderNotification(originalTime: Date) {
    let center = UNUserNotificationCenter.current()
    let reminderTime = originalTime.addingTimeInterval(30 * 60) // 30 minutos después
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
    
    // Crear contenido de la notificación de reenvío
    let content = UNMutableNotificationContent()
    content.title = "🌙 Recordatorio: Registro de Sueño"
    content.body = "No olvides registrar las horas de sueño del bebé"
    content.sound = .default
    content.categoryIdentifier = "SLEEP_REMINDER"
    content.userInfo = ["type": "daily_sleep_registration", "is_reminder": true]
    
    // Crear trigger basado en fecha/hora específica
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // Crear request con ID único para el reenvío
    let request = UNNotificationRequest(
      identifier: "sleep_notification_889_reminder",
      content: content,
      trigger: trigger
    )
    
    // Programar la notificación de reenvío
    center.add(request) { error in
      if let error = error {
        print("❌ iOS: Error programando notificación de reenvío: \(error.localizedDescription)")
      } else {
        print("✅ iOS: Notificación de reenvío programada para 30 minutos después")
      }
    }
  }
  
  private func cancelNativeNotification(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["sleep_notification_889", "sleep_notification_889_reminder"])
    print("✅ iOS: Notificación nativa cancelada")
    completion(true)
  }
  
  private func scheduleLactationNotification(
    timestamp: Int64,
    notificationId: Int,
    title: String,
    body: String,
    completion: @escaping (Bool) -> Void
  ) {
    let center = UNUserNotificationCenter.current()
    
    // Convertir timestamp a Date
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    
    // Guardar timestamp de la notificación para verificar si se registró
    let prefs = UserDefaults.standard
    prefs.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: "last_lactation_notification_time_\(notificationId)")
    
    // Crear contenido de la notificación
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    content.categoryIdentifier = "LACTATION_REMINDER"
    content.userInfo = ["type": "lactation_reminder", "notification_id": notificationId]
    
    // Crear trigger basado en fecha/hora específica
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // Crear request con ID único basado en notificationId
    let identifier = "lactation_notification_\(notificationId)"
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )
    
    // Programar la notificación
    center.add(request) { [weak self] error in
      if let error = error {
        print("❌ iOS: Error programando notificación de lactancia: \(error.localizedDescription)")
        completion(false)
      } else {
        print("✅ iOS: Notificación de lactancia programada para \(dateComponents) (ID: \(notificationId))")
        // Programar notificación de reenvío para 30 minutos después
        self?.scheduleLactationReminderNotification(
          originalTime: date,
          notificationId: notificationId,
          title: title,
          body: body
        )
        completion(true)
      }
    }
  }
  
  private func scheduleLactationReminderNotification(
    originalTime: Date,
    notificationId: Int,
    title: String,
    body: String
  ) {
    let center = UNUserNotificationCenter.current()
    let reminderTime = originalTime.addingTimeInterval(30 * 60) // 30 minutos después
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
    
    // Crear contenido de la notificación de reenvío
    let content = UNMutableNotificationContent()
    content.title = "🍼 Recordatorio: \(title)"
    content.body = "No olvides registrar la lactancia"
    content.sound = .default
    content.categoryIdentifier = "LACTATION_REMINDER"
    content.userInfo = ["type": "lactation_reminder", "notification_id": notificationId, "is_reminder": true]
    
    // Crear trigger basado en fecha/hora específica
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // Crear request con ID único para el reenvío
    let reminderNotificationId = notificationId + 10000
    let identifier = "lactation_notification_\(reminderNotificationId)"
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )
    
    // Programar la notificación de reenvío
    center.add(request) { error in
      if let error = error {
        print("❌ iOS: Error programando notificación de reenvío de lactancia: \(error.localizedDescription)")
      } else {
        print("✅ iOS: Notificación de reenvío de lactancia programada para 30 minutos después")
      }
    }
  }
  
  private func cancelLactationNotification(notificationId: Int, completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    let identifier = "lactation_notification_\(notificationId)"
    let reminderIdentifier = "lactation_notification_\(notificationId + 10000)"
    center.removePendingNotificationRequests(withIdentifiers: [identifier, reminderIdentifier])
    print("✅ iOS: Notificación de lactancia cancelada (ID: \(notificationId))")
    completion(true)
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  // Interceptar cuando se entrega una notificación para verificar si se debe mostrar el reenvío
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Verificar si es una notificación de reenvío
    if let isReminder = notification.request.content.userInfo["is_reminder"] as? Bool, isReminder {
      let prefs = UserDefaults.standard
      
      // Verificar tipo de notificación
      if let type = notification.request.content.userInfo["type"] as? String {
        if type == "daily_sleep_registration" {
          // Verificar si se registró el sueño
          let lastNotificationTime = prefs.integer(forKey: "last_sleep_notification_time")
          let lastRecordTime = prefs.integer(forKey: "last_sleep_record_time")
          
          // Si se registró después de la notificación, no mostrar reenvío
          if lastRecordTime > lastNotificationTime {
            print("✅ iOS: Se registró el sueño, cancelando notificación de reenvío")
            center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
            completionHandler([]) // No mostrar la notificación
            return
          }
        } else if type == "lactation_reminder" {
          // Verificar si se registró la lactancia
          if let notificationId = notification.request.content.userInfo["notification_id"] as? Int {
            let lastNotificationTime = prefs.integer(forKey: "last_lactation_notification_time_\(notificationId)")
            let lastRecordTime = prefs.integer(forKey: "last_lactation_record_time")
            
            // Si se registró después de la notificación, no mostrar reenvío
            if lastRecordTime > lastNotificationTime {
              print("✅ iOS: Se registró la lactancia, cancelando notificación de reenvío")
              center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
              completionHandler([]) // No mostrar la notificación
              return
            }
          }
        }
      }
    }
    
    // Mostrar la notificación normalmente
    completionHandler([.banner, .sound, .badge])
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
