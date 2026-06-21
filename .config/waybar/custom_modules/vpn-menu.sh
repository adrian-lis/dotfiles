#!/usr/bin/env bash

# Kolory dla minimalistycznego, profesjonalnego wyglądu CLI
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Domyślny profil bazowy
DEFAULT_PROFILE="VPN_PL"

show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "    ____                _                 __   ______  _   _"
    echo "   |  _ \ _ __ ___ | |_ ___  _ __    \ \   / /  _ \| \ | |"
    echo "   | |_) | '__/ _ \| __/ _ \| '_ \    \ \ / /| |_) |  \| |"
    echo "   |  __/| | | (_) | || (_) | | | |    \ V / |  __/| |\  |"
    echo "   |_|   |_|  \___/ \__\___/|_| |_|     \_/  |_|   |_| \_|"
    echo -e "${NC}"
    echo -e "    ${CYAN}Manager WireGuard (Proton VPN)${NC}"
    echo "========================================================="
}

# Funkcja pauzująca ekran
pause() {
    echo ""
    echo -e "${YELLOW}Naciśnij dowolny klawisz, aby wrócić do menu...${NC}"
    read -n 1 -s -r
}

# Sprawdzanie aktywnego interfejsu WireGuard
get_active_vpn() {
    # Pobiera nazwy aktywnych tuneli bezpośrednio z modułu jądra WG
    sudo wg show interfaces | head -n 1
}

while true; do
    show_banner
    
    ACTIVE_INTERFACE=$(get_active_vpn)
    
    # Wyświetlanie czytelnego statusu
    echo -n " Aktualny status połączenia: "
    if [[ -n "$ACTIVE_INTERFACE" ]]; then
        echo -e "${GREEN}[POŁĄCZONO] -> Aktywny interfejs: ${ACTIVE_INTERFACE}${NC}"
    else
        echo -e "${RED}[ROZŁĄCZONO]${NC}"
    fi
    echo "========================================================="
    
    # Przejrzysta lista opcji
    echo -e "  ${GREEN}1)${NC} Podłącz domyślny profil (${DEFAULT_PROFILE})"
    echo -e "  ${GREEN}2)${NC} Wybierz profil / serwer z listy (/etc/wireguard)"
    echo -e "  ${GREEN}3)${NC} Rozłącz aktywne połączenie VPN"
    echo -e "  ${GREEN}4)${NC} Pokaż szczegółowy status WireGuard (wg show)"
    echo -e "  ${GREEN}5)${NC} Szybki test szczelności i weryfikacja IP"
    echo -e "  ${GREEN}6)${NC} Zmień domyślną nazwę profilu"
    echo -e "  ${RED}7) Wyjście${NC}"
    echo "========================================================="
    
    read -p "Wybierz opcję [1-7]: " choice
    echo ""

    case $choice in
        1)
            if [[ -n "$ACTIVE_INTERFACE" ]]; then
                echo -e "${YELLOW}VPN jest już uruchomiony (${ACTIVE_INTERFACE}). Rozłącz go przed zmianą.${NC}"
            else
                echo -e "${CYAN}Uruchamianie domyślnego profilu: /etc/wireguard/${DEFAULT_PROFILE}.conf...${NC}"
                sudo resolvconf -u && sudo wg-quick up "$DEFAULT_PROFILE"
            fi
            pause
            ;;
            
        2)
            show_banner
            echo -e "${YELLOW}Dostępne profile WireGuard w systemie:${NC}"
            echo "--------------------------------------------------------- "
            
            # Dynamiczne skanowanie katalogu /etc/wireguard w poszukiwaniu plików .conf
            mapfile -t profiles < <(sudo ls /etc/wireguard/ | grep '\.conf$' | sed 's/\.conf$//')
            
            if [ ${#profiles[@]} -eq 0 ]; then
                echo -e "${RED}Brak plików konfiguracyjnych .conf w /etc/wireguard/${NC}"
            else
                for i in "${!profiles[@]}"; do
                    echo -e "  ${CYAN}$((i+1)))${NC} ${profiles[$i]}"
                done
                echo "--------------------------------------------------------- "
                read -p "Wybierz numer profilu [1-${#profiles[@]}]: " prof_num
                
                if [[ "$prof_num" =~ ^[0-9]+$ ]] && [ "$prof_num" -ge 1 ] && [ "$prof_num" -le "${#profiles[@]}" ]; then
                    SELECTED_PROFILE="${profiles[$((prof_num-1))]}"
                    
                    # Automatyczna rotacja (jeśli inny jest włączony, wyłącz go)
                    if [[ -n "$ACTIVE_INTERFACE" ]]; then
                        echo -e "${YELLOW}Zamykanie aktywnego tunelu: ${ACTIVE_INTERFACE}...${NC}"
                        sudo wg-quick down "$ACTIVE_INTERFACE"
                    fi
                    
                    echo -e "${GREEN}Podnoszenie nowego profilu: ${SELECTED_PROFILE}...${NC}"
                    sudo wg-quick up "$SELECTED_PROFILE"
                else
                    echo -e "${RED}Nieprawidłowy wybór!${NC}"
                fi
            fi
            pause
            ;;
            
        3)
            if [[ -z "$ACTIVE_INTERFACE" ]]; then
                echo -e "${YELLOW}Brak aktywnego połączenia WireGuard do rozłączenia.${NC}"
            else
                echo -e "${RED}Zamykanie tunelu ${ACTIVE_INTERFACE}...${NC}"
                sudo wg-quick down "$ACTIVE_INTERFACE"
            fi
            pause
            ;;
            
        4)
            if [[ -z "$ACTIVE_INTERFACE" ]]; then
                echo -e "${YELLOW}Brak danych do wyświetlenia. Brak aktywnego interfejsu.${NC}"
            else
                echo -e "${CYAN}--- STATYSTYKI NATIVE WIREGUARD ---${NC}"
                sudo wg show
            fi
            pause
            ;;
            
        5)
            echo -e "${CYAN}--- SPRAWDZANIE LOKALIZACJI SIECIOWEJ ---${NC}"
            echo -n "Pobieranie zewnętrznego IP... "
            current_ip=$(curl -s --max-time 5 https://ifconfig.me)
            if [[ -n "$current_ip" ]]; then
                echo -e "${YELLOW}$current_ip${NC}"
            else
                echo -e "${RED}Błąd połączenia (Timeout)${NC}"
            fi
            
            echo ""
            echo -e "${CYAN}--- KONTROLA AKTYWNYCH DNS (openresolv) ---${NC}"
            # Wyświetla aktualne serwery DNS w systemie
            if [ -f /etc/resolv.conf ]; then
                grep -v '^#' /etc/resolv.conf | grep 'nameserver' || echo -e "${RED}Brak skonfigurowanych serwerów DNS!${NC}"
            else
                echo -e "${RED}Plik /etc/resolv.conf nie istnieje.${NC}"
            fi
            pause
            ;;
            
        6)
            read -p "Podaj nową domyślną nazwę pliku (bez .conf): " new_name
            if [[ -n "$new_name" ]]; then
                DEFAULT_PROFILE="$new_name"
                echo -e "${GREEN}Zmieniono domyślny profil na: ${DEFAULT_PROFILE}${NC}"
            else
                echo -e "${RED}Anulowano. Nazwa nie może być pusta.${NC}"
            fi
            sleep 1.5
            ;;
            
        7)
            echo -e "${YELLOW}Zamykanie menedżera. Bezpieczne połączenie działa w tle kernel-space.${NC}"
            sleep 1
            clear
            exit 0
            ;;
            
        *)
            echo -e "${RED}Nieprawidłowa opcja! Wybierz cyfrę od 1 do 7.${NC}"
            sleep 1
            ;;
    esac
done
