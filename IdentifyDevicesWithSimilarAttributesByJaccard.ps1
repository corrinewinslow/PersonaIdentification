<#

CoPilot: give me a PowerShell algorithm for finding a list of devices with similar attributes based on a jaccard index greater than or equal 0.9 with grouping by similarity and where all devices only display once

PowerShell algorithm for finding devices with similar attributes based on a Jaccard index greater than or equal to 0.9. It groups devices by similarity and ensures that each device appears only once in the output.

Steps:
    1. Define a Function for Jaccard Index Calculation (Get-JaccardIndex):
        - This function takes two sets (arrays of attributes) and calculates the Jaccard index between them.
    2. Input Data:
        - Devices are represented in a hashtable ($devices) where each key is a device name, and each value is an array of attributes associated with that device.
    3. Initialize Empty Collections:
        - $groupedDevices: Stores groups of devices with similar attributes.
        - $processedDevices: Tracks devices that have already been assigned to a group, ensuring they don’t appear multiple times.
    4. Iterate Over Devices to Form Groups:
        - For each device (deviceA):
            - Skip if it has already been processed.
            - Initialize a group with deviceA.
            - Compare attributes of deviceA with all other devices (deviceB).
            - If deviceB meets the Jaccard index threshold (≥ 0.9) and is not already processed, add it to the group.
    5. Update Processed Devices:
        - Both deviceA and devices grouped with it (deviceB) are marked as processed to prevent duplication in other groups.
    6. Store the Group in groupedDevices:
        - Each device group is stored with a unique key in $groupedDevices.
    7. Output Results:
        - Iterate over the grouped results and print each group, ensuring each device appears only once.

Example Output for jaccard index 0.75:
    Group1: Device3
    Group2: Device2, Device4, Device1
    
    Devices in Group 2 have 3 attributes (75%) in common but Device3 has 2 attributes in common (50%) and is a separate group
#>

# Define a function to calculate the Jaccard index
function Get-JaccardIndex {
    param (
        [array]$SetA,
        [array]$SetB
    )
    $Intersection = ($SetA | Where-Object { $SetB -contains $_ }).Count
    $Union = ($SetA + $SetB | Sort-Object -Unique).Count
    return $Intersection / $Union
}

# Sample dataset: Device attributes as a hashtable
$devices = @{
    "Device1" = @("WiFi", "Bluetooth", "GPS")
    "Device2" = @("Bluetooth", "WiFi", "GPS")
    "Device3" = @("WiFi", "Bluetooth")
    "Device4" = @("GPS", "WiFi", "Bluetooth", "NFC")
}

# Group devices based on Jaccard index >= 0.9
$groupedDevices = @{}
$processedDevices = @()

foreach ($deviceA in $devices.Keys) {
    if ($processedDevices -contains $deviceA) {
        continue
    }

    $similarGroup = @($deviceA)
    foreach ($deviceB in $devices.Keys) {
        if ($deviceA -ne $deviceB -and -not ($processedDevices -contains $deviceB)) {
            $jaccardIndex = Get-JaccardIndex -SetA $devices[$deviceA] -SetB $devices[$deviceB]
            if ($jaccardIndex -ge 0.9) {
                $similarGroup += $deviceB
                $processedDevices += $deviceB
            }
        }
    }

    $processedDevices += $deviceA
    $groupedDevices[$deviceA] = $similarGroup
}

# Output grouped devices ensuring each device is displayed only once
foreach ($group in $groupedDevices.Values) {
    Write-Output "Group: $($group -join ', ')"
}
