#!/bin/bash
# Inspired by https://github.com/kmwoley/unRAID-Tools/blob/master/unraid_array_fan.sh

# User Defined variables
FAN_OFF_PWM=0
FAN_LOW_PWM=90
FAN_HIGH_PWM=255
FAN_START_PWM=100 # technically 90 but setting higher to ensure fan is running
LOW_TEMP=30
HIGH_TEMP=60
FRONT_FAN=/sys/class/hwmon/hwmon3/pwm3
REAR_FAN=/sys/class/hwmon/hwmon3/pwm4

# End of user defined variables
NUM_STEPS=$((HIGH_TEMP - LOW_TEMP))
PWM_INCREMENT=$(( (FAN_HIGH_PWM - FAN_LOW_PWM) / NUM_STEPS))
OUTPUT+="Linear PWM Range is "$FAN_LOW_PWM" to "$FAN_HIGH_PWM" in "$NUM_STEPS" increments of "$PWM_INCREMENT$'\n'

# Enable speed change on this fan if not already
if [ "$FRONT_FAN" != "1" ]; then
  echo 1 > "${FRONT_FAN}_enable"
fi

if [ "$REAR_FAN" != "1" ]; then
  echo 1 > "${REAR_FAN}_enable"
fi

PREVIOUS_SPEED=`cat $FRONT_FAN`
MOTHERBOARD_TEMP=`sensors acpitz-acpi-0 | grep "MB Temp" | grep -o '[0-9]*' | head -1`

echo "MB Temp: "$MOTHERBOARD_TEMP""

if [ "$MOTHERBOARD_TEMP" -le "$LOW_TEMP" ]; then 
  echo $FAN_OFF_PWM  > $FRONT_FAN # Turn off front fan, as hard drive fan already on.
  echo $FAN_LOW_PWM  > $REAR_FAN
  OUTPUT+="Setting pwm to: "$FAN_LOW_PWM$'\n'
elif [ "$MOTHERBOARD_TEMP" -ge "$HIGH_TEMP" ]; then
  echo $FAN_HIGH_PWM  > $FRONT_FAN
  echo $FAN_HIGH_PWM  > $REAR_FAN
  OUTPUT+="Setting pwm to: "$FAN_HIGH_PWM$'\n'
else
  # set fan to starting speed first to make sure it spins up then change it to low setting.
  if [ "$PREVIOUS_SPEED" -lt "$FAN_START_PWM" ]; then
    echo $FAN_START_PWM > $FRONT_FAN
    echo $FAN_START_PWM > $REAR_FAN
      sleep 4
  fi

  # Calculate target fan PWM speed as a linear value between FAN_HIGH_PWM and FAN_LOW_PWM
  FAN_LINEAR_PWM=$(( ((MOTHERBOARD_TEMP - LOW_TEMP) * PWM_INCREMENT) + FAN_LOW_PWM))
  echo $FAN_LINEAR_PWM > $FRONT_FAN
  echo $FAN_LINEAR_PWM > $REAR_FAN
  OUTPUT+="Setting pwm to: "$FAN_LINEAR_PWM$'\n'
fi

# produce output if the fan speed was changed
CURRENT_SPEED=`cat $REAR_FAN`
if [ "$PREVIOUS_SPEED" -ne "$CURRENT_SPEED" ]; then
  echo "Fan speed has changed to PWM: "$CURRENT_SPEED" MB temp: "$MOTHERBOARD_TEMP""
  echo "${OUTPUT}"
else
  echo "Fan speed unchanged. MB temp: "$MOTHERBOARD_TEMP" PWM: "$CURRENT_SPEED""
fi