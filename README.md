# VenusOS-BMR-Janitza
Service to use Janitza and BMR Meters with Venus OS
![Picture](https://github.com/patrick-dmxc/VenusOS-Janitza-UMG-96-RM/blob/main/Picture%201.png?raw=true)

## Installation (SetupHelper)
This driver is packaged to be used with [SetupHelper](https://github.com/kwindrem/SetupHelper), the standard Venus OS package manager. This ensures the driver automatically survives Venus OS firmware updates.

**Prerequisites:**
You must have [SetupHelper installed](https://github.com/kwindrem/SetupHelper) on your Cerbo GX first.

**Install the Driver:**
1. Connect to your Cerbo GX via SSH.
2. Run the following commands to download and install the package:
   ```bash
   mkdir -p /data/VenusOS-BMR-Janitza
   wget -O - https://github.com/kyros32/VenusOS-BMR-Janitza/archive/refs/heads/main.tar.gz | tar -xzf - -C /data/VenusOS-BMR-Janitza --strip-components=1
   chmod +x /data/VenusOS-BMR-Janitza/setup
   /data/VenusOS-BMR-Janitza/setup install
   ```
   
