##!/bin/bash
## /* ---- 💫 https://github.com/xuantruong1612 💫 ---- */
## Script tự động chuyển mạng WiFi nhanh nhất

#CONNECTIONS=("name-wifi-1" "name-wifi-2")
#CHECK_INTERVAL=1200 # 20 phút
#LOG_FILE="$HOME/.cache/hypr/logs/network-switcher.log"

#mkdir -p "$(dirname "$LOG_FILE")"

#while true; do
#    BEST_CONN=""
#    MIN_LATENCY=9999
#    CURRENT_CONN=$(nmcli -t -f NAME connection show --active | head -n1)
    
#    declare -A LATENCIES
#    declare -A AVAILABLE
#    declare -A SIGNALS
    
#    for CONN in "${CONNECTIONS[@]}"; do
#        # Kiểm tra connection có tồn tại không
#        if ! nmcli -t con show "$CONN" &>/dev/null; then
#            continue
#        fi
        
#        # Kiểm tra đã lưu mật khẩu chưa - CHỈ DÙNG MẠNG ĐÃ LƯU PASSWORD
#        PSK=$(nmcli -s -g 802-11-wireless-security.psk connection show "$CONN" 2>/dev/null)
#        if [ -z "$PSK" ]; then
#            # Chưa lưu mật khẩu, bỏ qua mạng này
#            continue
#        fi
        
#        SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$CONN" 2>/dev/null | cut -d: -f2)
#        BSSID=$(nmcli -t -f 802-11-wireless.bssid connection show "$CONN" 2>/dev/null | cut -d: -f2)
        
#        # Lấy signal strength
#        if [ ! -z "$BSSID" ] && [ "$BSSID" != "--" ]; then
#            SIGNAL=$(nmcli -f BSSID,SIGNAL dev wifi list | grep -i "$BSSID" | awk '{print $NF}' | head -n1)
#        else
#            SIGNAL=$(nmcli -f SSID,SIGNAL dev wifi list | grep "^${SSID}" | awk '{print $NF}' | sort -nr | head -n1)
#        fi
        
#        # Validate signal
#        if [ -z "$SIGNAL" ] || ! [[ "$SIGNAL" =~ ^[0-9]+$ ]]; then
#            AVAILABLE[$CONN]="no"
#            continue
#        fi
        
#        AVAILABLE[$CONN]="yes"
#        SIGNALS[$CONN]=$SIGNAL
        
#        # Tính latency
#        if [ "$CONN" == "$CURRENT_CONN" ]; then
#            # Ping thật cho mạng hiện tại
#            AVG_PING=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F'/' '{print $5}')
#            if [ -z "$AVG_PING" ]; then
#                AVG_PING=$((100 - SIGNAL))
#            else
#                # Làm tròn số thập phân
#                AVG_PING=$(printf "%.0f" "$AVG_PING")
#            fi
#        else
#            # Ước tính từ signal
#            AVG_PING=$((100 - SIGNAL))
#        fi
        
#        LATENCIES[$CONN]=$AVG_PING
        
#        # So sánh
#        if [ "$AVG_PING" -lt "$MIN_LATENCY" ]; then
#            MIN_LATENCY=$AVG_PING
#            BEST_CONN=$CONN
#        fi
#    done
    
#    # Tính chênh lệch
#    CURRENT_LATENCY="${LATENCIES[$CURRENT_CONN]:-9999}"
#    LATENCY_DIFF=$((CURRENT_LATENCY - MIN_LATENCY))
    
#    # Chuyển mạng nếu tốt hơn >10ms
#    if [ "$BEST_CONN" != "$CURRENT_CONN" ] && \
#       [ ! -z "$BEST_CONN" ] && \
#       [ "${AVAILABLE[$BEST_CONN]}" == "yes" ] && \
#       [ "$LATENCY_DIFF" -gt 10 ]; then
        
#        OLD_LATENCY="${LATENCIES[$CURRENT_CONN]:-N/A}"
#        OLD_SIGNAL="${SIGNALS[$CURRENT_CONN]:-N/A}"
#        NEW_SIGNAL="${SIGNALS[$BEST_CONN]:-N/A}"
        
#        # Chuyển mạng bằng nmcli con up (không cần password vì đã lưu)
#        if nmcli con up "$BEST_CONN" &>/dev/null; then
#            echo "$(date '+%Y-%m-%d %H:%M:%S'): $CURRENT_CONN (${OLD_LATENCY}ms, ${OLD_SIGNAL}%) → $BEST_CONN (${MIN_LATENCY}ms, ${NEW_SIGNAL}%)" >> "$LOG_FILE"
            
#            notify-send -u normal \
#                -i network-wireless-signal-excellent \
#                "Network Switched" \
#                "From: <b>$CURRENT_CONN</b> (${OLD_LATENCY}ms, ${OLD_SIGNAL}%)\n→ To: <b>$BEST_CONN</b> (${MIN_LATENCY}ms, ${NEW_SIGNAL}%)"
#        fi
#    fi
    
#    unset LATENCIES
#    unset AVAILABLE
#    unset SIGNALS
    
#    sleep $CHECK_INTERVAL
#done
