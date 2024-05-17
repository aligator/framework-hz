# hz.sh
Description
hz.sh is a bash script that changes the refresh rate of the laptop screen on a KDE environment. It uses kscreen-doctor to interact with the KDE screen settings.

## Usage
* `hz.sh <rate>`: Applies the specified refresh rate if available. If not, it lists available rates and exits with an error.
* `hz.sh`: Without an argument, it lists available refresh rates and prompts the user to select one.

For convenience, you can also use the refresh rate at the end of the script name, like hz60.sh.  
So you can just create a symlink: `ln -s hz.sh hz60.sh` 

To use it in KDE when unplugging the power just go to 
`System Settings -> Power Management -> Energy Saving ->`
* In `On Battery -> Run Script`: select the `hz60.sh` script
* In `On AC -> Run Script`: select the `hz165.sh` script

And apply the settings.  
Now when you unplug the power the refresh rate will be set to 60Hz and when you plug it back it will be set to 165Hz.

## Dependencies
The script depends on
* `jq`
* `kscreen-doctor`

## License
This script is released under the MIT license. See LICENSE for details.