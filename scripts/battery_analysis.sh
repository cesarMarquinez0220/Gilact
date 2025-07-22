#!/bin/bash

# Script para análisis de batería con Battery Historian
# Este script ayuda a analizar el consumo de batería de la aplicación Flutter

echo "🔋 Iniciando análisis de batería con Battery Historian..."

# Verificar si adb está disponible
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb no está instalado o no está en el PATH"
    exit 1
fi

# Verificar si hay dispositivos conectados
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No hay dispositivos Android conectados"
    exit 1
fi

# Crear directorio para logs
mkdir -p battery_logs

# Función para limpiar logs anteriores
cleanup_old_logs() {
    echo "🧹 Limpiando logs anteriores..."
    adb shell dumpsys batterystats --reset
    adb shell dumpsys batterystats --reset
}

# Función para iniciar la aplicación
start_app() {
    echo "🚀 Iniciando aplicación..."
    adb shell am start -n com.example.flutter_login/.MainActivity
    sleep 5
}

# Función para simular uso de la aplicación
simulate_app_usage() {
    echo "📱 Simulando uso de la aplicación..."
    
    # Simular navegación por la app
    for i in {1..10}; do
        echo "   Iteración $i/10"
        
        # Simular toques en diferentes partes de la pantalla
        adb shell input tap 200 400
        sleep 2
        adb shell input tap 400 600
        sleep 2
        adb shell input tap 300 500
        sleep 2
        
        # Simular scroll
        adb shell input swipe 300 800 300 200
        sleep 1
    done
}

# Función para generar reporte de batería
generate_battery_report() {
    echo "📊 Generando reporte de batería..."
    
    # Obtener estadísticas de batería
    adb shell dumpsys batterystats > battery_logs/batterystats.txt
    
    # Obtener información del sistema
    adb shell dumpsys power > battery_logs/power.txt
    
    # Obtener información de CPU
    adb shell dumpsys cpuinfo > battery_logs/cpuinfo.txt
    
    # Obtener información de memoria
    adb shell dumpsys meminfo > battery_logs/meminfo.txt
    
    echo "✅ Reportes generados en el directorio battery_logs/"
}

# Función para generar archivo para Battery Historian
generate_battery_historian_file() {
    echo "📈 Generando archivo para Battery Historian..."
    
    # Generar archivo HTML para Battery Historian
    adb shell dumpsys batterystats > battery_logs/batterystats.txt
    
    # Convertir a formato compatible con Battery Historian
    python3 -c "
import sys
import re

def parse_batterystats(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Extraer información relevante
    lines = content.split('\n')
    battery_data = []
    
    for line in lines:
        if 'Uid' in line and 'flutter_login' in line:
            battery_data.append(line)
        elif 'Discharge' in line:
            battery_data.append(line)
        elif 'Screen' in line:
            battery_data.append(line)
    
    return battery_data

# Generar archivo de salida
data = parse_batterystats('battery_logs/batterystats.txt')
with open('battery_logs/battery_historian_data.txt', 'w') as f:
    for line in data:
        f.write(line + '\n')

print('Archivo generado: battery_logs/battery_historian_data.txt')
" 2>/dev/null || echo "⚠️  Python no disponible, archivo raw generado"
}

# Función para mostrar estadísticas básicas
show_basic_stats() {
    echo "📋 Estadísticas básicas de batería:"
    echo "=================================="
    
    if [ -f "battery_logs/batterystats.txt" ]; then
        echo "🔋 Información de descarga:"
        grep -i "discharge" battery_logs/batterystats.txt | head -5
        
        echo ""
        echo "📱 Uso de pantalla:"
        grep -i "screen" battery_logs/batterystats.txt | head -3
        
        echo ""
        echo "⚡ Uso de CPU:"
        grep -i "cpu" battery_logs/batterystats.txt | head -3
    fi
}

# Función principal
main() {
    echo "🔋 Análisis de Batería - Flutter Login App"
    echo "=========================================="
    
    # Limpiar logs anteriores
    cleanup_old_logs
    
    # Iniciar aplicación
    start_app
    
    # Simular uso
    simulate_app_usage
    
    # Generar reportes
    generate_battery_report
    generate_battery_historian_file
    
    # Mostrar estadísticas básicas
    show_basic_stats
    
    echo ""
    echo "✅ Análisis completado!"
    echo ""
    echo "📁 Archivos generados:"
    echo "   - battery_logs/batterystats.txt (estadísticas completas)"
    echo "   - battery_logs/power.txt (información de energía)"
    echo "   - battery_logs/cpuinfo.txt (uso de CPU)"
    echo "   - battery_logs/meminfo.txt (uso de memoria)"
    echo "   - battery_logs/battery_historian_data.txt (datos para Battery Historian)"
    echo ""
    echo "🌐 Para visualizar con Battery Historian:"
    echo "   1. Ve a https://battery-historian.web.app/"
    echo "   2. Sube el archivo battery_historian_data.txt"
    echo "   3. Analiza los gráficos de consumo de batería"
}

# Ejecutar función principal
main 