# log file
if ($logfile -eq $null)
{
$logfile = "C:\temp\ADUsersAddedToTitle.txt"
New-Item $logfile -ItemType File
}

#OU Information 
$ous = 'OU=Groups,OU=Company,DC=poobah,DC=com'

#search for users
$users = Get-ADUser -Filter *  -searchbase 'OU=User,OU=Company,DC=poobah,DC=com' -Properties Title
$Titles = $users | Select-Object -ExpandProperty Title -Unique

Try {
    foreach ($Title in $Titles) {
      $group_name = "Title - $($Title)"
    if (Get-ADGroup -Filter { Name -eq $group_name }) {
        $users_in_Title = $users | Where-Object { $_.Title -eq $Title }
        foreach ($user in $users_in_Title) {
            Add-ADGroupMember -Identity $group_name -Members $user
      }
 }
 }
    $SuccessMailParams = @{
        To         = 'Example@Gmail.com'
        From       = 'Example@Gmail.com'
        SmtpServer = 'localhost'
        Subject    = 'Success'
        Body       = 'The script ran successfully'
    }
    Send-MailMessage @SuccessMailParams
}
Catch {
    $FailMailParams = @{
        To         = 'Example@Gmail.com'
        From       = 'Example@Gmail.com'
        SmtpServer = 'localhost'
        Subject    = 'Script Errors Out'
        Body       = @"
There was an error with the script:
$($Error.CateGoryInfo)
"@        
    }
    Send-MailMessage @FailMailParams   
} Finally {Add-Content $logfile + "Users ($Users.$Name) matched successfully"}
