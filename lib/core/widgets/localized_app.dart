import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/localization_service.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

/// Widget que envuelve MaterialApp y maneja el cambio de idioma dinámicamente
class LocalizedApp extends StatefulWidget {
  final Widget child;
  final LocalizationService localizationService;

  const LocalizedApp({
    super.key,
    required this.child,
    required this.localizationService,
  });

  @override
  State<LocalizedApp> createState() => _LocalizedAppState();
}

class _LocalizedAppState extends State<LocalizedApp> {
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.localizationService.getLocale();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is LocalSettingUpdated) {
          // Recargar el idioma cuando se actualiza
          final newLocale = widget.localizationService.getLocale();
          if (newLocale != _currentLocale) {
            setState(() {
              _currentLocale = newLocale;
            });
          }
        } else if (state is LocalSettingsLoaded) {
          // Actualizar locale cuando se cargan las configuraciones
          final newLocale = widget.localizationService.getLocale();
          if (newLocale != _currentLocale) {
            setState(() {
              _currentLocale = newLocale;
            });
          }
        }
      },
      child: MaterialApp(
        locale: _currentLocale ?? const Locale('es'),
        supportedLocales: widget.localizationService.getSupportedLocales(),
        // Aquí puedes agregar localizationsDelegates si usas paquetes de localización
        // localizationsDelegates: [
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalCupertinoLocalizations.delegate,
        // ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(
                1.0,
              ), // Prevenir escalado automático
            ),
            child: child ?? widget.child,
          );
        },
      ),
    );
  }
}
