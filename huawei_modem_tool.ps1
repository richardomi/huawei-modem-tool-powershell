<#
.SYNOPSIS
huawei_modem_tool.ps1 - Script to read SMS Inbox and send SMS using Huawei hilink modem, tested with model E3272

.DESCRIPTION 
Sends sms and reads sms inbox from huawei modem

.NOTES
Written by Richard Omi

v1.0, 26 March 2016 - Initial version
#>
$baseUrl = "http://192.168.1.1"
$tokenUrl = "/api/webserver/token"
$statusUrl = "/api/monitoring/status"
$sendSMSUrl = "/api/sms/send-sms"
$deviceInfoUrl = "/api/device/information"
$checkNotificationsUrl = "/api/monitoring/check-notifications"
$networkInfoUrl = "/api/net/current-plmn"
$smsInboxUrl = "/api/sms/sms-list"
$connectOrdisconnectUrl = "/api/dialup/dial"

$smsXMLStream = @"
<?xml version="1.0" encoding="UTF-8"?><request><Index>-1</Index><Phones><Phone>120</Phone></Phones><Sca></Sca><Content></Content><Length>0</Length><Reserved>1</Reserved><Date>2016-03-26 00:10:10</Date></request>
"@
$smsInboxXMLStream = @"
<?xml version="1.0" encoding="UTF-8"?><request><PageIndex>1</PageIndex><ReadCount>20</ReadCount><BoxType>1</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>0</UnreadPreferred></request>
"@
$connectXML = @"
<?xml version="1.0" encoding="UTF-8"?><request><Action>1</Action></request>
"@
$disconnectXML = @"
<?xml version="1.0" encoding="UTF-8"?><request><Action>0</Action></request>
"@


# get the webserver token
$tokenFile = $env:temp + "\modem_token.xml"
$client.DownloadFile($baseUrl + $tokenUrl, $tokenFile)
$tokenXMLdata = [xml](Get-Content $tokenFile)

# setup http client, headers
$client = new-object system.net.webclient
$client.Headers.Add("__RequestVerificationToken", $tokenXMLdata.response.token)
$client.Headers.Add("Content-Type", """text/xml; charset=UTF-8""")

$statusFile = $env:temp + "\modem_status.xml"
$deviceInfoFile = $env:temp + "\modem_dev_info.xml"
$smsInboxFile = $env:temp + "\modem_sms_inbox.xml"
$checkNotificationsFile = $env:temp + "\modem_notifications.xml"
$networkInfoFile = $env:temp + "\modem_net_info.xml"

$client.DownloadFile($baseUrl + $statusUrl, $statusFile)
$client.DownloadFile($baseUrl + $deviceInfoUrl, $deviceInfoFile)
$client.DownloadFile($baseUrl + $checkNotificationsUrl, $checkNotificationsFile)
$client.DownloadFile($baseUrl + $networkInfoUrl, $networkInfoFile)

$statusXMLdata = [xml](Get-Content $statusFile)
$deviceInfoXMLdata = [xml](Get-Content $deviceInfoFile)
$checkNotificationsXMLdata = [xml](Get-Content $checkNotificationsFile)
$networkInfoXMLdata = [xml](Get-Content $networkInfoFile)

Write-Host -ForegroundColor Magenta "Device Model: " $deviceInfoXMLdata.response.DeviceName
Write-Host -ForegroundColor Magenta "Network Name: " $networkInfoXMLdata.response.FullName
Write-Host -ForegroundColor Magenta "Web Server Token: " $tokenXMLdata.response.token
Write-Host -ForegroundColor Magenta "Connection Status: " $statusXMLdata.response.ConnectionStatus
Write-Host -ForegroundColor Magenta "Signal Status: " $statusXMLdata.response.SignalStrength
Write-Host -ForegroundColor Magenta "Unread Messages: " $checkNotificationsXMLdata.response.UnreadMessage
Write-Host -ForegroundColor Magenta "Sms Storage Full: " $checkNotificationsXMLdata.response.SmsStorageFull

# read the sms inbox ## uncomment to read sms inbox
#$client.UploadString($baseUrl + $smsInboxUrl, $smsInboxXMLStream)

# connect to data network
# $client.UploadString($baseUrl + $connectOrdisconnectUrl, $connectXML)
# update status + output to console
$client.DownloadFile($baseUrl + $statusUrl, $statusFile)
$statusXMLdata = [xml](Get-Content $statusFile)
Write-Host -ForegroundColor Magenta "Connection Status: " $statusXMLdata.response.ConnectionStatus
Write-Host -ForegroundColor Magenta "WanIPAddress: " $statusXMLdata.response.WanIPAddress

# send the sms message ## uncomment to send the sms
#$client.UploadString($baseUrl + $sendSMSUrl, $smsXMLStream)
