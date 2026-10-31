#!/bin/bash

LOG_FILE="access.log"

echo "Генерация тестового файла логов (300+ строк)..."
# Массивы для случайной генерации записей лога
IPS=("192.168.1.10" "10.0.0.5" "172.16.0.4" "192.168.1.20" "8.8.8.8" "127.0.0.1")
METHODS=("GET" "POST" "PUT" "DELETE")
ENDPOINTS=("/api/users" "/api/login" "/api/dashboard" "/api/products" "/api/settings")
STATUSES=("200" "201" "401" "404" "500" "503")

# Перезаписываем/создаем файл лога
> "$LOG_FILE"

# Генерируем 320 строк тестовых данных
for i in {1..320}; do
    IP=${IPS[$RANDOM % ${#IPS[@]}]}
    METHOD=${METHODS[$RANDOM % ${#METHODS[@]}]}
    ENDPOINT=${ENDPOINTS[$RANDOM % ${#ENDPOINTS[@]}]}
    STATUS=${STATUSES[$RANDOM % ${#STATUSES[@]}]}
   
    # Регулярная дата в формате [15/Aug/2026:10:15:32]
    TIMESTAMP="[15/Aug/2026:10:$(printf "%02d" $((RANDOM%60))):$(printf "%02d" $((RANDOM%60)))]"
   
    echo "$IP - - $TIMESTAMP \"$METHOD $ENDPOINT HTTP/1.1\" $STATUS" >> "$LOG_FILE"
done

echo "Файл $LOG_FILE успешно сгенерирован."
echo "=========================================="
echo "АНАЛИЗ ЛОГОВ:"
echo "=========================================="

# 1. Общее количество запросов
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE" | tr -d ' ')
echo "Общее количество запросов: $TOTAL_REQUESTS"

# 2. Топ-3 IP-адреса с наибольшим числом запросов (используем регулярное выражение для извлечения IP)
echo "Топ-3 IP-адреса с наибольшим числом запросов:"
grep -E -o "^([0-9]{1,3}\.){3}[0-9]{1,3}" "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 3 | awk '{print "  - IP: " $2 ", Запросов: " $1}'

# 3. Количество запросов с кодами 4xx и 5xx
ERR_4XX=$(awk '$9 ~ /^4/ {print $9}' "$LOG_FILE" | wc -l | tr -d ' ')
ERR_5XX=$(awk '$9 ~ /^5/ {print $9}' "$LOG_FILE" | wc -l | tr -d ' ')

echo "Количество запросов с кодами 4xx: $ERR_4XX"
echo "Количество запросов с кодами 5xx: $ERR_5XX"
