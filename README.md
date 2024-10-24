![shenron](src/resources/shenron.png)

# CK

CK is a package for CKMud, its hopes to be the best automation PERIOD. 

## Installation

`lua installPackage("https://github.com/CKMud-Mudlet-Scripts/CK/releases/latest/download/CK.mpackage")`

After installation `CK update` alias will take care of updating the script. 

## Usage

You must turn on `msdp` in settings to use this script.  Also while you are there disable MSSP and GMCP

This script should figure out who and what you are and be able to automaticlly configure itself and help you with the following

1. Automatic Buff Handling
2. Zetabot - Like autobot but better faster more insane
3. Auto Learning - Master all those skills, and learn news skills if you have all the pre-req skills. 

The script will from time to time issue the following commands so its aware of the various states of your character, though most comes from MSDP

1. status


# Aliases

`zetabot <aoe> <target>` - Start the zetabot, you don't need to be in the room of the target to start, and you don't have to the aoe mastered. If you have a Zeta it will automaticlly use it based on your Max Gravity from `status`

`autolearn <target> <speedwalk_to_isolation>` - Start the auto learn process using <target> to train every skill until its mastered.  Androids can ignore the speedwalk argument. 
The following CK constants should be used by organics 

1. `learning.recall_isolation` this will get you to an isolation tank from any location on the mud. Mine is "recall;s;w;enter vort;s"
2. `learning.return_to_target` this will get you back to the original target from the recall_isolation constant.  Mine is "crecall;n;n;n;e;n" this will change based on target

`redeem all` - Redeem all loot boxes until you have no more

`CK` - get a list of CK commands

`CK update` - update the CK script from github

`CK features` - list feature flags

`CK feature <name> <on|off>` - turn the feature on/off

`CK constants` - List Script Constants (These survive resetProfile())

`CK constant <name>=<value>` - Set a Script Constant

`CK pkg` - CK Package Manager

`CK pkg versions` - Show whats currently installed

`CK pkg install <map|chat>` - Get the map or chat scripts

`CK pkg update all` - Upgrade all install packages
`CK pkg update <name>` - Upgrade named package

`quit` - Quit but disable reconnecting first
