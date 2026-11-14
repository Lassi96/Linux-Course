#!/usr/bin/env bash

# Funktio levyn tilan tarkistamiseen ja varoituksen luomiseen
check_disk_status() {
    local usage_pct="$1"
    if [ "$usage_pct" -ge 80 ]; then
        echo "<span style=\"color: #f87171; font-weight: bold;\">WARNING ($usage_pct%)</span>"
    else
        echo "<span style=\"color: #4ade80; font-weight: bold;\">OK ($usage_pct%)</span>"
    fi
}

# Kerätään tarvittavat tiedot muuttujiin
GEN_TIME=$(/bin/date '+%Y-%m-%d %H:%M:%S %Z')
UPTIME_INFO=$(/usr/bin/uptime -p)
DISK_PCT_NUM=$(/usr/bin/df / | tail -1 | awk '{print $5}' | tr -d '%')
DISK_STATUS=$(check_disk_status "$DISK_PCT_NUM")
RAM_INFO=$(/usr/bin/free -h | awk '/Mem:/ {print "Usage: " $3 " / Total: " $2}')

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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lassi's Server Status</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            background-color: #0d1321;
            color: #e2e8f0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .card {
            background-color: #161e2e;
            border: 1px solid #253046;
            border-radius: 10px;
            padding: 32px 36px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.45);
            text-align: center;
        }
        h1 {
            color: #1d9bf0;
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .subtitle {
            color: #94a3b8;
            font-size: 13px;
            margin-bottom: 22px;
        }
        .status-box {
            background-color: #0f1523;
            border: 1px solid #1e293b;
            border-left: 4px solid #1d9bf0;
            border-radius: 6px;
            padding: 16px 18px;
            margin-bottom: 24px;
            text-align: left;
            font-size: 14px;
        }
        .status-row {
            display: flex;
            justify-content: space-between;
            padding: 7px 0;
            border-bottom: 1px solid #1a2234;
        }
        .status-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }
        .status-row:first-child {
            padding-top: 0;
        }
        .label {
            color: #94a3b8;
            font-weight: 600;
        }
        .value {
            color: #f8fafc;
            text-align: right;
        }
        .buttons {
            display: flex;
            justify-content: center;
            gap: 12px;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            color: #ffffff;
            transition: background-color 0.2s ease;
        }
        .btn-home {
            background-color: #334155;
        }
        .btn-home:hover {
            background-color: #475569;
        }
        .btn-github {
            background-color: #181c24;
            border: 1px solid #2d3748;
        }
        .btn-github:hover {
            background-color: #262c3a;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>Lassi's Server Status</h1>
        <p class="subtitle">Status loaded: $GEN_TIME</p>

        <div class="status-box">
            <div class="status-row">
                <span class="label">Server uptime:</span>
                <span class="value">$UPTIME_INFO</span>
            </div>
            <div class="status-row">
                <span class="label">Disk space (/):</span>
                <span class="value">$DISK_STATUS</span>
            </div>
            <div class="status-row">
                <span class="label">RAM usage:</span>
                <span class="value">$RAM_INFO</span>
            </div>
        </div>

        <div class="buttons">
            <a href="/" class="btn btn-home"><i class="fas fa-home"></i> HOME</a>
            <a href="https://github.com/" target="_blank" class="btn btn-github"><i class="fab fa-github"></i> GitHub</a>
        </div>
    </div>
</body>
</html>
EOF
