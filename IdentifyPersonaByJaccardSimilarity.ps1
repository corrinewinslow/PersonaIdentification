<#
  CoPilot: give me an algorithm in PowerShell for finding devices with almost the same attributes using a jaccard index
  The Jaccard Index measures the similarity between two sets by calculating the ratio of the intersection to the union of the sets. Here's a PowerShell implementation for finding devices with "almost the same attributes" based on a Jaccard Index threshold:
  
  How It Works:
  Input Devices: Each device is represented as a set of attributes in the $devices hashtable.
  
  Calculate Intersection and Union:
  
  The intersection is the set of shared attributes between two devices.
  
  The union is the combination of all unique attributes from both devices.
  
  Jaccard Index Formula: Jaccard Index = (Size of Intersection) / (Size of Union)
  
  Threshold Check: The script checks if the Jaccard Index meets or exceeds the specified threshold (e.g., 0.5 for 50% similarity).
  
  Output Results: Pairs of similar devices are displayed along with their Jaccard Index.
  
  Example Output:
  Given the input devices:
  
  Device1 = WiFi, Bluetooth, GPS
  Device2 = Bluetooth, WiFi, GPS
  Device3 = WiFi, Bluetooth
  Device4 = GPS, WiFi, Bluetooth, NFC
  With a Jaccard Threshold of 0.5, the output might look like:
  
  Devices with similar attributes based on Jaccard Index:
  Device1, Device2 (Jaccard Index: 1)
  Device1, Device3 (Jaccard Index: 0.666666666666667)
  Device1, Device4 (Jaccard Index: 0.75)
  Device2, Device4 (Jaccard Index: 0.75)
  Device3, Device4 (Jaccard Index: 0.5)
  This implementation is flexible and can handle various thresholds.
#>

# Define a hashtable of devices and their attributes
$devices = @{
    "Device1" = @("WiFi", "Bluetooth", "GPS")
    "Device2" = @("Bluetooth", "WiFi", "GPS")
    "Device3" = @("WiFi", "Bluetooth")
    "Device4" = @("GPS", "WiFi", "Bluetooth", "NFC")
}

# Define the Jaccard Index threshold (e.g., 0.5 means 50% similarity)
$jaccardThreshold = 0.5

# Create an empty array to store pairs of similar devices
$similarDevices = @()

# Compare each pair of devices
$deviceKeys = $devices.Keys
for ($i = 0; $i -lt $deviceKeys.Count; $i++) {
    for ($j = $i + 1; $j -lt $deviceKeys.Count; $j++) {
        $deviceA = $deviceKeys[$i]
        $deviceB = $deviceKeys[$j]

        # Get the sets of attributes for both devices
        $attributesA = $devices[$deviceA]
        $attributesB = $devices[$deviceB]

        # Calculate intersection and union of the two attribute sets
        $intersection = Compare-Object -ReferenceObject $attributesA -DifferenceObject $attributesB -IncludeEqual |
                        Where-Object { $_.SideIndicator -eq "==" } |
                        Select-Object -ExpandProperty InputObject

        $union = $attributesA + $attributesB | Sort-Object -Unique

        # Calculate Jaccard Index
        $jaccardIndex = $intersection.Count / $union.Count

        # Check if the Jaccard Index meets or exceeds the threshold
        if ($jaccardIndex -ge $jaccardThreshold) {
            $similarDevices += @("$deviceA, $deviceB (Jaccard Index: $jaccardIndex)")
        }
    }
}

# Display the results
if ($similarDevices.Count -gt 0) {
    Write-Host "Devices with similar attributes based on Jaccard Index:" -ForegroundColor Green
    foreach ($pair in $similarDevices) {
        Write-Host $pair
    }
} else {
    Write-Host "No devices with sufficient similarity found." -ForegroundColor Yellow
}
