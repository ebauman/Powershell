##########
#The MIT License (MIT)
#
#Copyright (c) 2015 Eamon Bauman

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#####
#
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
$csvLocation = ".\lbpmapping.csv"






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
If ($IPPrinters -ne $null) { $printers.Add($IPPrinters) }
If ($ClientNamePrinters -ne $null) { $printers.Add($ClientNamePrinters) }
If ($MACAddressPrinters -ne $null) { $printers.Add($MACAddressPrinters) }
If ($UserNamePrinters -ne $null) { $printers.Add($UserNamePrinters) }

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
