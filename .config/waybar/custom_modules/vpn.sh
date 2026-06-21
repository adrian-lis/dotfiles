#!/bin/bash

SERVER_NAME=$(ip -br link show | awk '{print $1}' | grep 'VPN' | head -n 1)

if [[ -n "$SERVER_NAME" ]]; then
    if [[ "$SERVER_NAME" == "VPN" ]]; then
        SERVER_NAME="Proton VPN"
    fi
    
    # Zwrócenie formatu JSON dla paska statusu
    echo "{\"text\": \" VPN\", \"alt\": \"connected\", \"tooltip\": \"VPN: Połączono\nSerwer: $SERVER_NAME\", \"class\": \"connected\"}"
else
    echo "{\"text\": \" VPN\", \"alt\": \"disconnected\", \"tooltip\": \"VPN: Rozłączono\", \"class\": \"disconnected\"}"
fi
