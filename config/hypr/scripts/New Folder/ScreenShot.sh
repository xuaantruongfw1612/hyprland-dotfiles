#!/bin/bash
# /* ---- 💫 Sửa lỗi Swappy & Tối ưu cho Hyprland 💫 ---- */ 

# --- Variables ---
time=$(date "+%d%m%y_%Hh%Mm%Ss%3Nms")
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}.png"

# Icons & Scripts paths
iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# Đảm bảo thư mục tồn tại
if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# --- Helper Functions ---

# Thông báo và xử lý sau khi chụp (Mở hoặc Xóa)
notify_view() {
	local filepath="$1"
	if [[ -e "$filepath" ]]; then
		# Phát âm thanh (nếu có script âm thanh)
		[[ -x "${sDIR}/Sounds.sh" ]] && "${sDIR}/Sounds.sh" --screenshot

		# Gửi thông báo
		resp=$(notify-send -t 5000 \
			-i "${iDIR}/picture.png" \
			-A "open=Open" \
			-A "delete=Delete" \
			"Screenshot Saved" "Path: $(basename "$filepath")")

		case "$resp" in
			"open")
				xdg-open "$filepath" &
				;;
			"delete")
				rm "$filepath" &
				;;
		esac
	else
		notify-send -u low -t 2000 "Screenshot" "Cancelled or Failed"
	fi
}

# Đếm ngược
countdown() {
	for sec in $(seq $1 -1 1); do
		notify-send -t 1000 -r 999 "Taking shot in: $sec"
		sleep 1
	done
	notify-send -C 999 # Xóa thông báo đếm ngược
}

# --- Main Functions ---

# 1. Chụp toàn màn hình ngay
shotnow() {
	cd "${dir}" && grim - | tee "$file" | wl-copy
	notify_view "${dir}/${file}"
}

# 2. Chụp toàn màn hình sau 5s
shot5() {
	countdown 5
	sleep 0.5 && cd "${dir}" && grim - | tee "$file" | wl-copy
	notify_view "${dir}/${file}"
}

# 3. Chụp toàn màn hình sau 10s
shot10() {
	countdown 10
	sleep 0.5 && cd "${dir}" && grim - | tee "$file" | wl-copy
	notify_view "${dir}/${file}"
}

# 4. Chụp cửa sổ đang active
shotwin() {
	# Lấy thông tin cửa sổ active bằng hyprctl và jq
	window_geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
	window_class=$(hyprctl -j activewindow | jq -r '(.class)')
	
	if [[ "$window_geom" == "null" || -z "$window_geom" ]]; then
		notify-send -u low "Screenshot" "No active window found"
		return
	fi

	local win_file="Screenshot_${time}_${window_class}.png"
	
	grim -g "$window_geom" "${dir}/${win_file}"
	wl-copy < "${dir}/${win_file}"
	notify_view "${dir}/${win_file}"
}

# 5. Chụp vùng chọn (Chỉ lưu, KHÔNG mở Swappy)
shotarea() {
	# Dùng slurp để lấy vùng chọn
	local geom
	geom=$(slurp)

	if [[ -n "$geom" ]]; then
		grim -g "$geom" "${dir}/${file}"
		wl-copy < "${dir}/${file}"
		notify_view "${dir}/${file}"
	else
		notify-send -u low "Screenshot" "Selection cancelled"
	fi
}

# 6. Chụp vùng chọn và MỞ SWAPPY (Đã sửa lỗi Image Not Loaded)
shotswappy() {
	# B1: Chọn vùng trước
	local geom
	geom=$(slurp)

	# Nếu bấm Esc thì thoát luôn
	if [[ -z "$geom" ]]; then
		notify-send -u low "Screenshot" "Cancelled"
		return
	fi

	# B2: Tạo file tạm có đuôi .png (Bắt buộc cho Swappy)
	local tmpfile
	tmpfile=$(mktemp --suffix=.png)

	# B3: Chụp vào file tạm
	grim -g "$geom" "$tmpfile"

	# B4: Mở Swappy và dọn dẹp sau khi đóng
	if [[ -s "$tmpfile" ]]; then
		# Phát âm thanh chụp trước khi mở app
		[[ -x "${sDIR}/Sounds.sh" ]] && "${sDIR}/Sounds.sh" --screenshot
		swappy -f "$tmpfile"
		rm "$tmpfile"
	fi
}

# --- Execute Flags ---

if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--in5" ]]; then
	shot5
elif [[ "$1" == "--in10" ]]; then
	shot10
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
elif [[ "$1" == "--swappy" ]]; then
	shotswappy
else
	echo -e "Available Options : --now --in5 --in10 --win --area --swappy"
fi

exit 0
