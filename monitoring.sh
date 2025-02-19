#!/bin/sh

PROCESS_NAME="test"
INTERVAL=60

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/monitoring.log
}

PROCESS_PID=$(pgrep -x "$PROCESS_NAME")

while true; do
    
    # проверка, что процесс существует и имеет PID
    if pgrep -x "$PROCESS_NAME" > /dev/null; then

        log_message "Process '$PROCESS_NAME' was started."

        # is the current process the initial one
        if [[ "$PROCESS_PID" != "$(pgrep -x "$PROCESS_NAME")" ]]; then
            
            log_message "Process '$PROCESS_NAME' was restarted."

        fi

    fi

    # получаем статус ответа от https://test.com/monitoring/test/api
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://test.com/monitoring/test/api")

    if [ "$RESPONSE" -ne 200 ]; then
        
        log_message "The monitoring is unavailable."
    
    fi

    # обновляем PROCESS_PID для следующего цикла
    PROCESS_PID=$(pgrep -x "$PROCESS_NAME")
    
    sleep "$INTERVAL"
    
done