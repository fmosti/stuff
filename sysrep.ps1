
param(
    [Parameter(Mandatory=$true)]
    [string]
    $AdminPassword
)
 
Start-Transcript -Path 'c:\bootstrap-transcript.txt' -Force
Set-StrictMode -Version Latest
Set-ExecutionPolicy Unrestricted
 
$log = 'c:\Bootstrap.txt'
 
while (($AdminPassword -eq $null) -or ($AdminPassword -eq ''))
{
    $AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host "Enter a non-null / non-empty Administrator password" -AsSecureString)))
}
 
 
$systemPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::System)
$sysNative = [IO.Path]::Combine($env:windir, "sysnative")
#http://blogs.msdn.com/b/david.wang/archive/2006/03/26/howto-detect-process-bitness.aspx
$Is32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and ($Env:PROCESSOR_ARCHITEW6432 -eq $null))
Add-Content $log -value "Is 32-bit [$Is32Bit]"
 
#http://msdn.microsoft.com/en-us/library/ms724358.aspx
$coreEditions = @(0x0c,0x27,0x0e,0x29,0x2a,0x0d,0x28,0x1d)
$IsCore = $coreEditions -contains (Get-WmiObject -Query "Select OperatingSystemSKU from Win32_OperatingSystem" | Select -ExpandProperty OperatingSystemSKU)
Add-Content $log -value "Is Core [$IsCore]"
 
# move to home, PS is incredibly complex :)
cd $Env:USERPROFILE
Set-Location -Path $Env:USERPROFILE
[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
 
#change admin password
net user Administrator qweasd123
Add-Content $log -value "Changed Administrator password"
 
$client = new-object System.Net.WebClient
 

&winrm quickconfig `-q
&winrm set winrm/config/client/auth '@{Basic="true"}'
&winrm set winrm/config/service/auth '@{Basic="true"}'
&winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Add-Content $log -value "Ran quickconfig for winrm"
 
#wait a bit, it's windows after all
Start-Sleep -m 10000
 
#Write-Host "Press any key to reboot and finish image configuration"
#[void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
