#!/bin/bash

# User Defined variables
FAN_LOW_PWM=30
FAN_HIGH_PWM=255
LOW_TEMP=28
HIGH_TEMP=60
CPU_FAN=/sys/class/hwmon/hwmon3/pwm2
# End of user defined variables

# Enable speed change on this fan if not already
if [ "$CPU_FAN" != "1" ]; then
  echo 1 > "${CPU_FAN}_enable"
fi

i=0
sleep_time=9
while [ $i -lt 6 ]; do # 6 ten-second intervals in 1 minute
    PREVIOUS_SPEED=`cat $CPU_FAN`
    CPU_TEMP=`sensors coretemp-isa-0000 | grep "CPU Temp" | grep -o '[0-9]*' | head -1`
    CPU_TEMP=$((CPU_TEMP)) # Convert to Number

    echo "CPU Temp: "$CPU_TEMP""

    if ((CPU_TEMP <= LOW_TEMP)); then
        NEW_PWM=$((FAN_LOW_PWM))
    elif ((CPU_TEMP >= HIGH_TEMP)); then
        NEW_PWM=$((FAN_HIGH_PWM))
    elif ((CPU_TEMP >= 30 && CPU_TEMP < 35)); then
        NEW_PWM=$((FAN_LOW_PWM + 35))
    elif ((CPU_TEMP >= 35 && $CPU_TEMP < 40)); then
        NEW_PWM=$((FAN_LOW_PWM + 35*2))
    elif ((CPU_TEMP >= 40 && CPU_TEMP < 50)); then
        NEW_PWM=$((FAN_LOW_PWM + 35*3))
    elif ((CPU_TEMP >= 50 && CPU_TEMP < 55)); then
        NEW_PWM=$((FAN_LOW_PWM + 35*4))
    elif ((CPU_TEMP >= 55 && CPU_TEMP < 60)); then
        NEW_PWM=$((FAN_LOW_PWM + 35*5))
    else
        # Assuming a failed reading
        NEW_PWM=$((FAN_HIGH_PWM))
        echo "Unknown temp "$CPU_TEMP""
    fi

    echo $NEW_PWM  > $CPU_FAN

    # produce output if the fan speed was changed
    CURRENT_SPEED=`cat $CPU_FAN`
    if [ "$PREVIOUS_SPEED" -ne "$CURRENT_SPEED" ]; then
        echo "Speed Changed. PWM: "$PREVIOUS_SPEED" -> "$CURRENT_SPEED" CPU Temp: "$CPU_TEMP""
    else
        echo "No Speed Change. PWM: "$CURRENT_SPEED" CPU Temp: "$CPU_TEMP" "
    fi

    echo "Sleeping for "$sleep_time" seconds"
    sleep $sleep_time
    i=$(( i + 1 ))
done
