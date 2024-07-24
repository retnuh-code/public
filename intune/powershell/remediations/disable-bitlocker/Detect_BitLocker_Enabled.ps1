#=============================================================================================================================
#
# Script Name:     Detect_BitLocker_Enabled.ps1
# Description:     Detect if BitLocker is enabled on any volume
# Notes:           Exit 1 if BitLocker is enabled on any volume to trigger remediation
#
#=============================================================================================================================

# Define Variables
$results = 0

try {
    # Get all BitLocker volumes
    $BLV = Get-BitLockerVolume
    foreach ($volume in $BLV) {
        if ($volume.ProtectionStatus -eq 'On') {
            # BitLocker is enabled
            $results = 1
            Write-Host "Match"
            exit 1
        }
    }
    # BitLocker not enabled on any volume
    Write-Host "No_Match"
    exit 0
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}
