<#
CoPilot: give me a PowerShell algorithm for finding devices with the same exact same attributes

How it Works:
Normalization: Attributes are sorted and joined into a single string (e.g., "Bluetooth, GPS, WiFi") to ensure consistent comparison.

Mapping: Devices with identical attribute sets are grouped together in the attributeMap.

Filtering: Only attribute sets that are associated with more than one device are considered "matches."

Output: Matching devices are displayed in groups.

Output Example:
For the input devices:

Device1 = WiFi, Bluetooth, GPS
Device2 = Bluetooth, WiFi, GPS
Device3 = NFC, Bluetooth
Device4 = WiFi, Bluetooth, GPS
The output will be:

Devices with matching attributes:
Device1, Device2, Device4

# Define a hashtable of devices and their attributes
$devices = @{
    "Device1" = @("WiFi", "Bluetooth", "GPS")
    "Device2" = @("Bluetooth", "WiFi", "GPS")
    "Device3" = @("NFC", "Bluetooth")
    "Device4" = @("WiFi", "Bluetooth", "GPS")
}
#>

# Create an empty hashtable to map normalized attribute sets to device identifiers
$attributeMap = @{}

# Process each device
foreach ($device in $devices.GetEnumerator()) {
    # Normalize attributes by sorting and joining them (to create a unique string for comparison)
    $normalizedAttributes = ($device.Value | Sort-Object) -join ","

    # Check if the normalized attribute set already exists in the map
    if ($attributeMap.ContainsKey($normalizedAttributes)) {
        # Add the device to the existing list
        $attributeMap[$normalizedAttributes] += $device.Key
    } else {
        # Create a new list with this device
        $attributeMap[$normalizedAttributes] = @($device.Key)
    }
}

# Extract groups of matching devices
$matchingGroups = $attributeMap.Values | Where-Object { $_.Count -gt 1 }

# Display the results
if ($matchingGroups.Count -gt 0) {
    Write-Host "Devices with matching attributes:" -ForegroundColor Green
    foreach ($group in $matchingGroups) {
        Write-Host ($group -join ", ")
    }
} else {
    Write-Host "No devices with matching attributes found." -ForegroundColor Yellow
}
