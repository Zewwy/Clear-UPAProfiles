########################################################################################################################## 
# Author: Zewwy (Aemilianus Kehler)
# Date:   Nov 4, 2021
# Script: Clear-UPAProfiles
# This script shows users of any provided group within SharePoints UAP.
# Kudos to Salaudeen Rajack from https://www.sharepointdiary.com/2015/07/remove-all-user-profiles-in-sharepoint-using-powershell.html
# Required parameters: 
#   A valid  SharePoint Site Collection URL.
#   Best to be run from a SharePoint Mgmt Console with farm admin... Why? ¯\_(ツ)_/¯
##########################################################################################################################

##########################################################################################################################
#   Variables
##########################################################################################################################

#MyLogoArray
$MylogoArray = @("#####################################","# This script is brought to you by: #","#                                   #","#             Zewwy                 #","#                                   #","#####################################"," ")
$ScriptName = "Clear-UPAProfiles; cause some SharePoint features just suck ass.`n"

#The Varible used to display wrong URL provided, or not found
$BadURL = @("Sorry, the string you entered ","is not a valid Site Collection.")

$SQLServer = "Server\instance"
$DB = "WSS_Content"

#Static Variables
$pswheight = (get-host).UI.RawUI.MaxWindowSize.Height
$pswwidth = (get-host).UI.RawUI.MaxWindowSize.Width

##########################################################################################################################
#   Functions
##########################################################################################################################
function Centeralize()
{
  param(
  [Parameter(Position=0,Mandatory=$true)]
  [string]$S,
  [Parameter(Position=1,Mandatory=$false,ParameterSetName="color")]
  [string]$C
  )
    $sLength = $S.Length
    $padamt =  "{0:N0}" -f (($pswwidth-$sLength)/2)
    $PadNum = $padamt/1 + $sLength #the divide by one is a quick dirty trick to covert string to int
    $CS = $S.PadLeft($PadNum," ").PadRight($PadNum," ") #Pad that shit
    if ($C) #if variable for color exists run below
    {    
        Write-Host $CS -ForegroundColor $C #write that shit to host with color
    }
    else #need this to prevent output twice if color is provided
    {
        $CS #write that shit without color
    }
}

function confirm($tit, $msg)
{
    #function variables, generally only the first two need changing
    $title = $tit
    $message = $msg

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "This means Yes"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "This means No"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $Options, 0)
    Write-Host " "
    Switch ($result)
        {
              0 { Return $true }
              1 { Return $false }
        }
}


##########################################################################################################################
#   Run, Bitch! RUN!
##########################################################################################################################
#Notify User to enter the Site Collection URL then check if it exits.
Centeralize "Please enter a SP Site Collection URL`n"
Write-host "SharePoint Site Collection URL: " -ForegroundColor Magenta -NoNewline
$SPSitecolstr = Read-Host
Write-Host " "
Centeralize "Verifying SharePoint Site Collection URL, Please Wait...`n" "White"
if ($SPSiteCol=Get-SPSite $SPSitecolstr -EA SilentlyContinue)
{
    $DB = $SPSiteCol.ContentDatabase.Name
    $SQLServer = $SPSiteCol.ContentDatabase.Server
    Centeralize "Phhhh, ok good guess, that is a site collection here's what the systems got:`n" "Cyan"
    Centeralize "SqlSever\Instance: $SQLServer Using Database: $DB `n" "White"
    #Get Required Objects Defined
    $ServiceContext  = Get-SPServiceContext -site $SPSiteCol
    $UserProfileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($ServiceContext)
    #Ger all User Profiles
    $UserProfiles = $UserProfileManager.GetEnumerator()
    Foreach ($Profile in $UserProfiles)
    {
        $ti = "Removing User Profile: "+$Profile["AccountName"]
        $ms = "Are you sure?"
         
        #Remove User Profile
        if(confirm $ti $ms){$UserProfileManager.RemoveUserProfile($profile["AccountName"])}
    }

}
else
{
    $SPSitecolstr = "`""+$SPSitecolstr+"`" "
    $BadURL = $BadURL[0] + $SPSitecolstr + $BadURL[1]
    foreach($str in $BadURL){Centeralize $str "red"}
}
