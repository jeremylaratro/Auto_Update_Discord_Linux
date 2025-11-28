# Auto_Update_Discord_Linux
Simple script for updating Discord on Linux. This script will:
- auto-install Discord, if not already installed
- auto update Discord to latest version

For weekly auto-updates:
run: `crontab -e`
add: `0 3 * * 0 /home/$USER/apps/discord_update.sh`

Tested on Debian and Fedora.

Configurations:
- Script installs Discord to `/home/$USER/apps/`. Change this path in the script and crontab entry if you want it installed elsewhere. 
