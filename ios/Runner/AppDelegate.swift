import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var screenProtectionChannel: FlutterMethodChannel?
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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
