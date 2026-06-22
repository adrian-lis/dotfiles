#!/bin/bash

# Folder na cache w pamięci RAM
CACHE_DIR="/dev/shm/waybar-netspeed"
mkdir -p "$CACHE_DIR"

RX_TOTAL=0
TX_TOTAL=0

for path in /sys/class/net/*; do
    [ -d "$path" ] || continue
    interface=$(basename "$path")
    [ "$interface" = "lo" ] && continue
    
    if [ -f "$path/statistics/rx_bytes" ] && [ -f "$path/statistics/tx_bytes" ]; then
        rx=$(cat "$path/statistics/rx_bytes")
        tx=$(cat "$path/statistics/tx_bytes")
        
        RX_TOTAL=$((RX_TOTAL + rx))
        TX_TOTAL=$((TX_TOTAL + tx))
    fi
done

if [ -f "$CACHE_DIR/rx" ] && [ -f "$CACHE_DIR/tx" ]; then
    # Czytamy stare wartości do zmiennych
    RX_PREV=$(cat "$CACHE_DIR/rx")
    TX_PREV=$(cat "$CACHE_DIR/tx")
    
    # Obliczamy różnicę (bajty na sekundę)
    RBPS=$((RX_TOTAL - RX_PREV))
    TBPS=$((TX_TOTAL - TX_PREV))
    
    # Zabezpieczenie przed ujemnymi wartościami (np. po resecie połączenia sieciowego)
    [ $RBPS -lt 0 ] && RBPS=0
    [ $TBPS -lt 0 ] && TBPS=0
else
    RBPS=0
    TBPS=0
fi

# Zapis stanu do cache za pomocą operacji atomowej (wskazanie na nowy plik i szybka zamiana)
echo "$RX_TOTAL" > "$CACHE_DIR/rx.tmp" && mv "$CACHE_DIR/rx.tmp" "$CACHE_DIR/rx"
echo "$TX_TOTAL" > "$CACHE_DIR/tx.tmp" && mv "$CACHE_DIR/tx.tmp" "$CACHE_DIR/tx"

# Przeliczenie bajtów na bity (x8) dla jednostek Mb/s i Kb/s
RX_BITS=$((RBPS * 8))
TX_BITS=$((TBPS * 8))

format_speed_bits() {
    local bits=$1
    if [ $bits -lt 1000 ]; then
        echo "0 Kb/s"
    elif [ $bits -lt 1000000 ]; then
        echo "$((bits / 1000)) Kb/s"
    else
        echo "$(awk "BEGIN {printf \"%.1f\", $bits/1000000}") Mb/s"
    fi
}

DOWN=$(format_speed_bits $RX_BITS)
UP=$(format_speed_bits $TX_BITS)

echo " $DOWN  $UP"
