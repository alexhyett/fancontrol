# fancontrol

My Unraid server uses an MSI Z97 Gaming 5 Motherboard which I got secondhand. Unfortunately it has a couple of issues:

1. The onboard CPU temperature doesn't work. This means the CPU fan doesn't ramp up when the CPU gets hot.
2. The lowest the case fans can go down to is 50% using the smart control on the motherboard. This is still quite loud when using Noctua fans as it equates to 800rpm.

I have these scripts to control the fans in my case.

Fans:
hwmon3/fan2_input - hwmon3/pwm2 - CPU
hwmon3/fan3_input - hwmon3/pwm3 - Front Bottom
hwmon3/fan5_input - hwmon3/pwm5 - Front Top (Array fan) - This currently being controlled by the Fan Control Plugin in unraid.
hwmon3/fan4_input - hwmon3/pwm4 - Rear Exhaust