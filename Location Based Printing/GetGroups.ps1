<#
.DESCRIPTION
    This function gets the current user's username and looks them up
    in Active Directory to get a String array of all the group names
    they belong to.

.AUTHOR
    Sam Weinkauf
#>

function GetGroups
{
    <# Get Enviroment Inforamtion #>
    $volatileObject = Get-ItemProperty -Path "HKCU:\Volatile Environment"

    <# Pull Username from enviroment info #>
    [string]$U = $volatileObject.USERNAME
    
    <# Populate Group List #>
    $UN = Get-ADUser $U -Properties MemberOf
    $Groups = ForEach ($Group in ($UN.MemberOf))
    {   (Get-ADGroup $Group).Name
    }
    $Groups = $Groups | Sort
    return $Groups
}