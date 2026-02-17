#!/bin/bash

# --- COLORES Y ESTÉTICA ---
export TERM=xterm-256color
BLANCO="\e[1;37m"
AZUL="\e[1;36m"
AMARILLO="\e[1;33m"
ROJO="\e[1;31m"
VERDE="\e[1;32m"
RESET="\e[0m"

# --- CONFIGURACIÓN DE RUTAS ---
# Detectamos el usuario real si se ejecuta con sudo
REAL_USER=$(logname 2>/dev/null || echo $USER)
DESKTOP_PATH="/home/$REAL_USER/Desktop"
[ ! -d "$DESKTOP_PATH" ] && DESKTOP_PATH="/home/$REAL_USER/Escritorio"

# --- FUNCIONES DE APOYO ---

function check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${ROJO}Error: Este script requiere privilegios de superusuario.${RESET}"
        echo -e "${AZUL}Por favor, ejecútalo con: ${BLANCO}sudo $0${RESET}"
        exit 1
    fi
}

function spinner() {
    local pid=$1
    local delay=0.1
    local spinstr="'|/-\'"
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function mostrar_logo() {
    clear
    echo -e "${AZUL}"
    echo "  █████  ██      ██      ██   ██ ███    ███ ███████ "
    echo " ██   ██ ██      ██      ██   ██ ████  ████ ██      "
    echo " ███████ ██      ██      ███████ ██ ████ ██ █████   "
    echo " ██   ██ ██      ██           ██ ██  ██  ██ ██      "
    echo " ██   ██ ███████ ███████      ██ ██      ██ ███████ "
    echo -e "${BLANCO}  Versión 1.0 - Auditoría de Red Profesional${RESET}"
    echo -e "${AZUL}  --------------------------------------------------${RESET}"
    echo -e "${AMARILLO}  [!] Descargo de responsabilidad: Uso doméstico y educativo.${RESET}"
    echo -e "${AMARILLO}  El usuario es el único responsable de su uso legal.${RESET}\n"
}

function guardar_resultado() {
    local contenido="$1"
    local tipo="$2"
    echo -e "\n${AZUL}¿Deseas guardar el resultado en un archivo? (s/n)${RESET}"
    read -r respuesta
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then
        local fecha=$(date +"%Y%m%d_%H%M")
        local nombre_archivo="Auditoria_${tipo}_${fecha}.txt"
        local ruta_completa="$DESKTOP_PATH/$nombre_archivo"
        
        echo -e "--- AUDITORÍA ALL4ME ---" > "$ruta_completa"
        echo -e "Fecha: $(date)" >> "$ruta_completa"
        echo -e "Tipo: $tipo" >> "$ruta_completa"
        echo -e "------------------------\n" >> "$ruta_completa"
        echo -e "$contenido" >> "$ruta_completa"
        
        # Ajustar permisos para que el usuario normal pueda leerlo
        chown $REAL_USER:$REAL_USER "$ruta_completa"
        echo -e "${VERDE}Archivo guardado en: $ruta_completa${RESET}"
    fi
    echo -e "${AZUL}Pulse cualquier tecla para continuar...${RESET}"
    read -n 1 -s
}

# --- MENÚS PRINCIPALES ---

function menu_principal() {
    while true; do
        mostrar_logo
        echo -e "${BLANCO}1.${RESET} Escaneo automático (Detección de Interfaz/Subred)"
        echo -e "${BLANCO}2.${RESET} Opciones de Descubrimiento de Hosts"
        echo -e "${BLANCO}3.${RESET} Análisis Exhaustivo (Vulnerabilidades)"
        echo -e "${BLANCO}4.${RESET} Salir"
        echo -ne "\n${AZUL}Selecciona una opción: ${RESET}"
        read -r opt

        case $opt in
            1) escaneo_automatico ;;
            2) menu_descubrimiento ;;
            3) analisis_exhaustivo ;;
            4) exit 0 ;;
            *) echo -e "${ROJO}Opción no válida.${RESET}"; sleep 1 ;;
        esac
    done
}

function escaneo_automatico() {
    mostrar_logo
    echo -e "${AZUL}[i] Detectando configuración de red...${RESET}"
    
    INTERFAZ=$(ip route | grep default | awk '{print $5}' | head -n1)
    SUBRED=$(ip route | grep $INTERFAZ | grep kernel | awk '{print $1}' | head -n1)
    
    echo -e "${BLANCO}Comando: ${AZUL}ip route${RESET}"
    echo -e "${BLANCO}Motivo: ${RESET}Identificar la interfaz activa y el rango CIDR de la red local."
    echo -e "\n${VERDE}Interfaz detectada:${BLANCO} $INTERFAZ${RESET}"
    echo -e "${VERDE}Subred detectada:${BLANCO} $SUBRED${RESET}\n"
    
    echo -e "${AZUL}Pulse cualquier tecla para volver al menú...${RESET}"
    read -n 1 -s
}

function menu_descubrimiento() {
    mostrar_logo
    echo -e "${AMARILLO}[!] AVISO PROFESIONAL:${RESET}"
    echo -e "Los escaneos ${BLANCO}sigilosos${RESET} son más lentos y evitan disparar alarmas (IDS)."
    echo -e "Los escaneos ${ROJO}agresivos${RESET} son rápidos pero fáciles de detectar y bloquear."
    echo -e "--------------------------------------------------\n"
    
    echo -e "${BLANCO}1.${RESET} arp-scan Sigiloso (Intervalos largos)"
    echo -e "${BLANCO}2.${RESET} arp-scan Agresivo (Rápido)"
    echo -e "${BLANCO}3.${RESET} netdiscover Pasivo (Escucha silenciosa)"
    echo -e "${BLANCO}4.${RESET} nmap Stealth Scan (SYN Scan)"
    echo -e "${BLANCO}5.${RESET} Volver"
    
    read -r dopt
    case $dopt in
        1) 
            COMANDO="arp-scan -l -i 250 -x -q"
            DESC="Usa el protocolo ARP. El intervalo de 250ms (-i) lo hace más lento para evitar saturar la tabla ARP."
            ejecutar_escaneo "$COMANDO" "ArpScan_Sigiloso" "$DESC"
            ;;
        2) 
            COMANDO="arp-scan -l -r 5 -t 500"
            DESC="Envía múltiples reintentos rápidamente. Muy efectivo pero ruidoso."
            ejecutar_escaneo "$COMANDO" "ArpScan_Agresivo" "$DESC"
            ;;
        3)
            COMANDO="netdiscover -p -S -P -L" # Modo pasivo
            DESC="No envía paquetes; solo escucha el tráfico ARP existente en la red para detectar hosts."
            echo -e "${AZUL}Escuchando durante 30 segundos...${RESET}"
            timeout 30s netdiscover -p -L > /tmp/netscan.txt
            cat /tmp/netscan.txt
            guardar_resultado "$(cat /tmp/netscan.txt)" "Netdiscover_Pasivo"
            ;;
        4)
            SUBRED_ACTUAL=$(ip route | grep kernel | awk '{print $1}' | head -n1)
            COMANDO="nmap -sS -Pn -n -T2 --top-ports 100 --open $SUBRED_ACTUAL"
            DESC="Escaneo SYN (-sS). No completa la conexión TCP, lo que lo hace 'invisible' para logs de aplicaciones."
            ejecutar_escaneo "$COMANDO" "Nmap_Stealth" "$DESC"
            ;;
        5) return ;;
    esac
}

function ejecutar_escaneo() {
    local cmd=$1
    local tipo=$2
    local desc=$3
    
    mostrar_logo
    echo -e "${AZUL}Ejecutando:${BLANCO} sudo $cmd${RESET}"
    echo -e "${BLANCO}Propósito:${RESET} $desc\n"
    
    # Ejecución con spinner
    sudo $cmd > /tmp/scan_res.txt &
    spinner $!
    
    RESULTADO=$(cat /tmp/scan_res.txt)
    echo -e "\n${BLANCO}$RESULTADO${RESET}"
    guardar_resultado "$RESULTADO" "$tipo"
}

function analisis_exhaustivo() {
    mostrar_logo
    echo -ne "${AZUL}Introduce la IP del objetivo: ${RESET}"
    read -r target_ip
    
    if [[ -z "$target_ip" ]]; then
        echo -e "${ROJO}IP no válida.${RESET}"
        sleep 1; return
    fi

    COMANDO="nmap -sV -sC -Pn -T4 --script vuln $target_ip"
    DESC="Detecta versiones de servicios (-sV), aplica scripts predeterminados (-sC) y busca vulnerabilidades conocidas (--script vuln)."
    
    ejecutar_escaneo "$COMANDO" "Analisis_Vulnerabilidades" "$DESC"
}

# --- INICIO ---
check_sudo
menu_principal