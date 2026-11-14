#!/usr/bin/env bash

# Funktio levyn tilan tarkistamiseen ja varoituksen luomiseen
check_disk_status() {
    local usage_pct="$1"
    if [ "$usage_pct" -ge 80 ]; then
        echo "<span style=\"color: red;\">WARNING ($usage_pct%)</span>"
    else
        echo "<span style=\"color: green;\">OK ($usage_pct%)</span>"
    fi
}

# Kerätään tarvittavat tiedot muuttujiin
GEN_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
UPTIME_INFO=$(uptime -p)
DISK_PCT_NUM=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
DISK_STATUS=$(check_disk_status "$DISK_PCT_NUM")
RAM_INFO=$(free -h | awk '/Mem:/ {print "Usage: " $3 " / Total: " $2}')

# Määritellään polku, jonne HTML tallennetaan.
REPORT_DIR="/var/www/html/week3"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/index.html"

# Kirjoitetaan HTML-raportti tiedostoon
cat << EOF > "$REPORT_FILE"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Lassi's Server Status</title>
</head>
<body>
    <h1>Server Status</h1>
    <p><strong>Status loaded:</strong> $GEN_TIME</p>
    
    <h2>System info</h2>
    <ul>
        <li><strong>Server uptime:</strong> $UPTIME_INFO</li>
        <li><strong>Disk space (/):</strong> $DISK_STATUS</li>
        <li><strong>Ram usage (RAM):</strong> $RAM_INFO</li>
    </ul>
</body>
</html>
EOF
