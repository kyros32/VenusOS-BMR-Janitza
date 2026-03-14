# VenusOS-Janitza
Service to use Janitza Meters with Venus OS
![Picture](https://github.com/patrick-dmxc/VenusOS-Janitza-UMG-96-RM/blob/main/Picture%201.png?raw=true)

## Installation (SetupHelper)
This driver is packaged to be used with [SetupHelper](https://github.com/kwindrem/SetupHelper), the standard Venus OS package manager. This ensures the driver automatically survives Venus OS firmware updates.

**Prerequisites:**
You must have [SetupHelper installed](https://github.com/kwindrem/SetupHelper) on your Cerbo GX first.

**Install the Driver:**
1. Connect to your Cerbo GX via SSH.
2. Run the following commands to download and install the package:
   ```bash
   wget -qO - [https://github.com/kyros32/VenusOS-Janitza/archive/refs/heads/main.tar.gz](https://github.com/kyros32/VenusOS-Janitza/archive/refs/heads/main.tar.gz) | tar -xzf - -C /data
   mv /data/VenusOS-Janitza-main /data/VenusOS-Janitza
   /data/VenusOS-Janitza/setup
   ```
