# VenusOS-BMR-Janitza
Service to use Janitza and BMR Meters with Venus OS
![Picture](https://github.com/patrick-dmxc/VenusOS-Janitza-UMG-96-RM/blob/main/Picture%201.png?raw=true)

## Installation (SetupHelper)
This driver is packaged to be used with [SetupHelper](https://github.com/kwindrem/SetupHelper), the standard Venus OS package manager. This ensures the driver automatically survives Venus OS firmware updates.

**Prerequisites:**
You must have [SetupHelper installed](https://github.com/kwindrem/SetupHelper) on your Cerbo GX first.
1. Connect to your Cerbo GX via SSH.
2. Run the following commands to download and install the package:
   ```bash
   wget -qO - https://github.com/kwindrem/SetupHelper/archive/latest.tar.gz | tar -xzf - -C /data
   rm -rf /data/SetupHelper
   mv /data/SetupHelper-latest /data/SetupHelper
   /data/SetupHelper/setup
   ```
## Installation of VenusOS-BMR-Janitza package
**Install the Driver (Automatically via Github):**

You do not need to use SSH to install this driver! You can do it directly from your Cerbo GX Touchscreen or Remote Console.

   1. Go to Settings -> Package Manager -> Inactive Packages -> click on package named "new" on your Venus OS screen.
   2. Enter the following details:

         - GitHub user: kyros32

         - GitHub repository: VenusOS-BMR-Janitza

         - Branch: main

   3. Tap "Proceed"
   4. The package will now appear in your list. Tap on VenusOS-BMR-Janitza and select Install.

**Install the Driver (Manually via SSH):**

1. Connect to your Cerbo GX via SSH.
2. Run the following commands to download and install the package:
   ```bash
   rm -rf /data/VenusOS-BMR-Janitza
   rm -rf /data/setupOptions/VenusOS-BMR-Janitza
   mkdir -p /data/VenusOS-BMR-Janitza
   wget -O - https://github.com/kyros32/VenusOS-BMR-Janitza/archive/refs/heads/main.tar.gz | tar -xzf - -C /data/VenusOS-BMR-Janitza --strip-components=1
   chmod +x /data/VenusOS-BMR-Janitza/setup
   bash -x /data/VenusOS-BMR-Janitza/setup install
   ```
3. Verification: Once installed, "VenusOS-BMR-Janitza" will appear in the Victron Remote Console / GUI under Settings -> Package Manager -> Active packages.

You can easily uninstall or update the driver directly from the touchscreen or Remote Console in the future without needing to use SSH again.

## Supported Meters
UMG 96 RM [all variations with Modbus RTU or Modbus TCP]

UMG 96 PQ [all variations with Modbus RTU or Modbus TCP] (untested)

BMR PLA33 [all variations with Modbus RTU or Modbus TCP] (untested)

** Issues **
If its not working, please open an issue and we can fix it.

**Your Meter is not Supported**
Open an Issue and we can see if its possible to implement your Meter as well.

## Note
In the event that Victron changes, adds, or removes methods from register.py in future Venus OS updates, it is possible that the script may need adjustments to function correctly again.
   
