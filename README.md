# Powershell

This is a repository containing all of my work in Powershell. 

## Location Based Printing
This script (LocationBasedPrinting.ps1) is used to add printers when a user connects to a VMware View desktop. The script should be deployed using Group Policy, and set as PowerShell login script during user logon. 

It requires an accompanying CSV file containing a mapping of printers and VMware View's Volatile Environment properties. An example file has been uploaded (see lbmapping.csv).
