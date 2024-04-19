#!/bin/bash
# Inspired by https://github.com/kmwoley/unRAID-Tools/blob/master/unraid_array_fan.sh

# User Defined variables
FAN_LOW_PWM=30
FAN_HIGH_PWM=255
FAN_START_PWM=50 # technically 30 but setting higher to ensure fan is running
LOW_TEMP=28
HIGH_TEMP=60
CPU_FAN=/sys/class/hwmon/hwmon3/pwm2
# End of user defined variables

NUM_STEPS=$((HIGH_TEMP - LOW_TEMP))
PWM_INCREMENT=$(( (FAN_HIGH_PWM - FAN_LOW_PWM) / NUM_STEPS))
OUTPUT+="Linear PWM Range is "$FAN_LOW_PWM" to "$FAN_HIGH_PWM" in "$NUM_STEPS" increments of "$PWM_INCREMENT$'\n'

# Enable speed change on this fan if not already
if [ "$CPU_FAN" != "1" ]; then
  echo 1 > "${CPU_FAN}_enable"
fi

PREVIOUS_SPEED=`cat $CPU_FAN`
CPU_TEMP=`sensors coretemp-isa-0000 | grep "CPU Temp" | grep -o '[0-9]*' | head -1`

echo "CPU Temp: "$CPU_TEMP""

if [ "$CPU_TEMP" -le "$LOW_TEMP" ]; then 
  echo $FAN_LOW_PWM  > $CPU_FAN
  OUTPUT+="Setting pwm to: "$FAN_LOW_PWM$'\n'
elif [ "$CPU_TEMP" -ge "$HIGH_TEMP" ]; then
  echo $FAN_HIGH_PWM > $CPU_FAN
  OUTPUT+="Setting pwm to: "$FAN_HIGH_PWM$'\n'
else
  # set fan to starting speed first to make sure it spins up then change it to low setting.
  if [ "$PREVIOUS_SPEED" -lt "$FAN_START_PWM" ]; then
    echo $FAN_START_PWM > $CPU_FAN
      sleep 4
  fi

  # Calculate target fan PWM speed as a linear value between FAN_HIGH_PWM and FAN_LOW_PWM
  FAN_LINEAR_PWM=$(( ((CPU_TEMP - LOW_TEMP) * PWM_INCREMENT) + FAN_LOW_PWM))
  echo $FAN_LINEAR_PWM > $CPU_FAN
  OUTPUT+="Setting pwm to: "$FAN_LINEAR_PWM$'\n'
fi

# produce output if the fan speed was changed
CURRENT_SPEED=`cat $CPU_FAN`
if [ "$PREVIOUS_SPEED" -ne "$CURRENT_SPEED" ]; then
  echo "Fan speed has changed to PWM: "$CURRENT_SPEED" CPU temp: "$CPU_TEMP""
  echo "${OUTPUT}"
else
  echo "Fan speed unchanged. CPU temp: "$CPU_TEMP" PWM: "$CURRENT_SPEED""
fi