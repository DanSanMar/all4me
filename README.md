# ALL4ME - Auditoría de Red 🛡️

**ALL4ME** es un script interactivo en Bash diseñado para la exploración y auditoría de seguridad en redes locales. Combina herramientas estándar bajo una interfaz visual intuitiva con soporte para colores y gestión automática de reportes.

## 📖 Descripción Detallada

**ALL4ME** es una solución de automatización en Bash diseñada para simplificar las fases de **reconocimiento y enumeración** en una auditoría de red. El script actúa como una capa de orquestación que integra herramientas de bajo nivel, permitiendo al auditor centrarse en el análisis de datos en lugar de en la sintaxis compleja de los comandos.

### 🛡️ Arquitectura y Funcionamiento

El script está estructurado en cuatro módulos principales que cubren el ciclo de vida inicial de un pentesting de red:

#### 1. Módulo de Reconocimiento Inteligente
A diferencia de otros scripts que requieren la entrada manual del rango de red, ALL4ME utiliza el comando `ip route` para identificar la **interfaz de red activa** y calcular automáticamente la **subred CIDR**. Esto minimiza errores humanos y acelera el despliegue en entornos desconocidos.

#### 2. Motores de Descubrimiento de Hosts (Capa 2 y 3)
El script ofrece tres metodologías distintas para encontrar dispositivos vivos:
* **ARP-Scan (Capa 2):** Ideal para redes locales donde se busca rapidez. Incluye un modo **Sigiloso** que introduce retardos de 250ms entre paquetes para evitar saturar las tablas ARP de los switches y pasar desapercibido ante sistemas de monitoreo básicos.
* **Netdiscover (Modo Pasivo):** Una de las funciones más potentes. En este modo, el script no envía tráfico; simplemente pone la interfaz en modo escucha para capturar peticiones ARP, permitiendo identificar hosts sin generar una sola alerta en la red.
* **Nmap Stealth (Capa 3):** Utiliza escaneos de tipo **SYN Scan (-sS)**. Al no completar el apretón de manos TCP (Three-way handshake), el rastro dejado en los logs de las aplicaciones del objetivo es mínimo.

#### 3. Motor de Análisis de Vulnerabilidades
Para el análisis profundo, utiliza el motor de scripts de Nmap (NSE). El script lanza una batería de pruebas que incluyen:
* Detección exacta de **versiones de servicios** (`-sV`).
* Ejecución de scripts predeterminados de seguridad (`-sC`).
* Escaneo específico de **vulnerabilidades conocidas** mediante la categoría `vuln`, que busca CVEs críticos de forma automatizada.

#### 4. Gestión Inteligente de Reportes
Una característica distintiva es su sistema de salida. Aunque el script se ejecute con privilegios de `root` (necesarios para el manejo de interfaces), detecta quién es el **usuario real** tras la sesión de `sudo`. 
* **Auto-detección de ruta:** Localiza carpetas de "Desktop" o "Escritorio" dinámicamente.
* **Gestión de Permisos:** Al finalizar, aplica un `chown` automático para que el reporte pertenezca al usuario normal, eliminando la necesidad de cambiar permisos manualmente para leer o mover el archivo.

---

### ⚙️ Especificaciones Técnicas
* **Lenguaje:** Bash Scripting.
* **Compatibilidad:** Sistemas basados en Debian (Kali Linux, Parrot OS, Ubuntu).
* **Estética:** Soporte para terminales xterm-256color con feedback visual mediante estados de carga (spinners).

---

## ✨ Características principales

* 🔍 **Detección Automática:** Identifica interfaces de red y rangos CIDR sin configuración manual.
* 📡 **Descubrimiento Inteligente:** Incluye modos sigilosos, agresivos y pasivos (escucha).
* 🛡️ **Análisis de Vulnerabilidades:** Implementa scripts de Nmap para detectar fallos conocidos.
* 📄 **Generación de Reportes:** Guarda resultados en el Escritorio con gestión de permisos.

---

## 🛠️ Requisitos previos

El script requiere las siguientes herramientas instaladas en tu sistema Linux:

```bash
sudo apt update
sudo apt install nmap arp-scan netdiscover -y
```

---

## 🚀 Instalación y Uso

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/DanSanMar/all4me.git
   cd all4me
   ```

2. **Dale permisos de ejecución:**
   ```bash
   chmod +x all4me.sh
   ```

3. **Ejecútalo con privilegios de root:**
   ```bash
   sudo ./all4me.sh
   ```

---

## 📋 Menú de Herramientas

| Opción | Comando Base | Propósito |
| :--- | :--- | :--- |
| **Escaneo Automático** | `ip route` | Detectar red local. |
| **ARP Sigiloso** | `arp-scan -i 250` | Evitar detección por IDS. |
| **Netdiscover Pasivo** | `netdiscover -p` | Escucha silenciosa. |
| **Nmap Stealth Scan** | `nmap -sS` | Escaneo SYN "invisible". |
| **Análisis Exhaustivo** | `nmap --script vuln` | Buscar vulnerabilidades. |

---

## 📁 Gestión de Reportes

El script detecta automáticamente tu usuario para guardar los logs en:
* `~/Desktop/Auditoria_...txt` (o `/Escritorio/`).

Los archivos se crean con permisos para tu usuario normal, facilitando su lectura posterior.

---

## ⚠️ Descargo de Responsabilidad (Disclaimer)

Este script ha sido creado exclusivamente con fines **educativos y de auditoría doméstica**. El uso de estas herramientas contra infraestructuras sin autorización previa es ilegal. El autor no se hace responsable del mal uso de este software.

---
**Desarrollado por DanSanMar**
