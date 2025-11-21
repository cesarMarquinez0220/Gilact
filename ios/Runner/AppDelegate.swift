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
    center.add(request) { error in
      if let error = error {
        print("❌ iOS: Error programando notificación nativa: \(error.localizedDescription)")
        completion(false)
      } else {
        print("✅ iOS: Notificación nativa programada para \(dateComponents)")
        completion(true)
      }
    }
  }
  
  private func cancelNativeNotification(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["sleep_notification_889"])
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
    center.add(request) { error in
      if let error = error {
        print("❌ iOS: Error programando notificación de lactancia: \(error.localizedDescription)")
        completion(false)
      } else {
        print("✅ iOS: Notificación de lactancia programada para \(dateComponents) (ID: \(notificationId))")
        completion(true)
      }
    }
  }
  
  private func cancelLactationNotification(notificationId: Int, completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    let identifier = "lactation_notification_\(notificationId)"
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
    print("✅ iOS: Notificación de lactancia cancelada (ID: \(notificationId))")
    completion(true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
