##########
# Powershell Location Based Printing Script
# 
# Author: Eamon Bauman <eamon@eamonbauman.com> (@eamonb)
# 
# Version: 1.0 (August 12th, 2015)
#
# This script can be used to add printers badsed on registry items presented by VMware View.
# It works by pulling information from a configuration CSV, matching Volatile Environment items
# against that CSV, and then looping over the printers to add. The printers are added using 
# printui.dll.
#
# The following items are currently supported:
# - Client IP Address
# - Client Machine Name
# - Client MAC Address
# - Connecting username
#
##########

#####
# CONFIGURATION ITEMS
#####

# CSV File Location
$csvLocation = ".\lbmapping.csv"






#####
# CODE
#####

# Grab a listing of registry items from HKCU:\Volatile Environmnet
$volatileObject = Get-ItemProperty -Path "HKCU:\Volatile Environment"

# Import the CSV
$csv = Import-Csv $csvLocation

# Create an ArrayList to contain the matched printers. 
# Needs to be an ArrayList to get around the fixed size problem with arrays.
[System.Collections.ArrayList]$printers = @() 

# Get all printers that are matched by IP
$IPPrinters = $csv | Where-Object { $_.IPAddress -match $volatileObject.ViewClient_Broker_Remote_IP_Address }
# Get all printers that are matched by client name
$ClientNamePrinters = $csv | Where-Object { $_.ClientName -match $volatileObject.ViewClient_Machine_Name }
# Get all printers that are matched by MAC address
$MACAddressPrinters = $csv | Where-Object { $_.MACAddress -match $volatileObject.ViewClient_MAC_Address }
# Get all printers that are matched by username
$UserNamePrinters = $csv | Where-Object { $_.User -match $volatileObject.ViewClient_Broker_UserName }

# Add the matched printers to the main printer list, if the match does not return null.
# This is required because the ArrayList.Add() method will add a $null if there's no match
If ($IPPrinters -ne $null) 
{
    If ($IPPrinters -is [System.Array]) 
    {
        $printers.AddRange($IPPrinters) 
    }
    else
    {
        $printers.Add($IPPrinters)
    }
}
If ($ClientNamePrinters -ne $null) 
{ 
    If ($ClientNamePrinters -is [System.Array])
    {
        $printers.AddRange($ClientNamePrinters) 
    }
    else
    {
        $printers.Add($ClientNamePrinters)
    }
}
If ($MACAddressPrinters -ne $null) 
{
    If ($MACAddressPrinters -is [System.Array])
    { 
        $printers.AddRange($MACAddressPrinters) 
    }
    else
    {
        $printers.Add($MACAddressPrinters)
    }
}
If ($UserNamePrinters -ne $null)
{ 
    If ($UserNamePrinters -is [System.Array])
    {
        $printers.AddRange($UserNamePrinters) 
    }
    else
    {
        $printers.Add($UserNamePrinters)
    }
}

# Loop over the printers
Foreach ($printer in $printers) 
{
    # Construct printer location
    $printerLocation = "/n" + $printer.PrinterLocation

    if ($printer.Default -eq "True")
    {
        # If the printer is supposed to be default, add a /y argument
        Start-Process rundll32.exe -ArgumentList @('printui.dll,PrintUIEntry', '/y', '/in', '/q', $printerLocation) -Wait
    } 
    else 
    {
        # If the printer is not default, omit the /y
        Start-Process rundll32.exe -ArgumentList @('printui.dll,PrintUIEntry', '/in', '/q', $printerLocation) -Wait
    }
}
