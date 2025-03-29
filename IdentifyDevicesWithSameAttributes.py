<#
CoPilot: give me a Python algorithm for finding devices with the same exact same attributes

Algorithm: Match Pairs of Devices with Same Attributes
Input:
  A list of devices, where each device has a unique identifier and a collection of attributes.

Step 1: Normalize Attributes
  For each device, normalize its attributes (e.g., sort them alphabetically or convert them to a standardized format) to ensure consistent comparison.

Step 2: Create a Dictionary
  Create an empty dictionary attribute_map where:
  Keys are attribute sets (or hashed representations for efficiency).
  Values are lists of device identifiers.

Step 3: Map Devices
  Iterate through the list of devices.
  For each device:
    Normalize its attribute set.
    Check if the normalized attribute set exists as a key in attribute_map:
    If yes, append the device identifier to the corresponding value (list of identifiers).
    If no, add the attribute set as a new key with the device identifier as its first value.

Step 4: Extract Groups
  Iterate through attribute_map:
  For each key (attribute set), check its value (list of device identifiers).
  If the list has more than one device, these devices share the same attributes.

Output:
  Return a list of groups, where each group contains identifiers of devices with matching attributes.

For the example above, the output will identify devices with matching attributes:
  [['Device1', 'Device2', 'Device4']]
#>

def find_matching_devices(devices):
    attribute_map = {}

    for device_id, attributes in devices.items():
        # Normalize attributes (convert to a frozenset for consistent comparison)
        normalized_attributes = frozenset(attributes)

        if normalized_attributes in attribute_map:
            attribute_map[normalized_attributes].append(device_id)
        else:
            attribute_map[normalized_attributes] = [device_id]

    # Extract groups of matching devices
    matching_groups = [
        group for group in attribute_map.values() if len(group) > 1
    ]

    return matching_groups

# Example Usage
devices = {
    "Device1": {"WiFi", "Bluetooth", "GPS"},
    "Device2": {"Bluetooth", "WiFi", "GPS"},
    "Device3": {"NFC", "Bluetooth"},
    "Device4": {"WiFi", "Bluetooth", "GPS"},
}

print(find_matching_devices(devices))

