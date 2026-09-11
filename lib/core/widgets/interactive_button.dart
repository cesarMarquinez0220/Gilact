import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

/// Botón interactivo que respeta las configuraciones de sonido y vibración
class InteractiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enableSound;
  final bool enableVibration;

  const InteractiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.enableSound = true,
    this.enableVibration = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              // Reproducir sonido y vibrar si están habilitados
              if (enableSound || enableVibration) {
                final soundService = GetIt.instance<SoundService>();
                final vibrationService = GetIt.instance<VibrationService>();

                await Future.wait([
                  if (enableSound) soundService.playClickSound(),
                  if (enableVibration) vibrationService.vibrateOnButtonPress(),
                ]);
              }

              // Ejecutar la acción
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Switch interactivo que respeta las configuraciones de sonido y vibración
class InteractiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enableSound;
  final bool enableVibration;

  const InteractiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enableSound = true,
    this.enableVibration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) async {
              // Reproducir sonido y vibrar si están habilitados
              if (enableSound || enableVibration) {
                final soundService = GetIt.instance<SoundService>();
                final vibrationService = GetIt.instance<VibrationService>();

                await Future.wait([
                  if (enableSound) soundService.playClickSound(),
                  if (enableVibration) vibrationService.selectionClick(),
                ]);
              }

              // Ejecutar el cambio
              onChanged?.call(newValue);
            },
      activeThumbColor: const Color.fromARGB(255, 3, 166, 150),
    );
  }
}

