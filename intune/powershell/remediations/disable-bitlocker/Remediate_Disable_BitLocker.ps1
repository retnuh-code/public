#=============================================================================================================================
#
# Script Name:     Remediate_Disable_BitLocker.ps1
# Description:     Disable BitLocker on all volumes where it is enabled
# Notes:           This script will be triggered by Intune remediation
#
#=============================================================================================================================

try {
    # Get all BitLocker volumes
    $BLV = Get-BitLockerVolume
    foreach ($volume in $BLV) {
        if ($volume.ProtectionStatus -eq 'On') {
            # Disable BitLocker on the volume
            Disable-BitLocker -MountPoint $volume.MountPoint
            Write-Output "BitLocker disabled on drive $($volume.MountPoint)"
        } else {
            Write-Output "BitLocker not enabled on drive $($volume.MountPoint)"
        }
    }
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}
