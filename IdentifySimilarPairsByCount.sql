/*
CoPilot: give me an algorithm in SQL for finding pairs of devices with almost the same attributes using a count-based threshold

Explanation:
Self-Join (Devices d1 INNER JOIN Devices d2) Matches attributes between two different devices (d1.DeviceID and d2.DeviceID). The condition d1.DeviceID < d2.DeviceID ensures each pair is only compared once.

Count Shared Attributes (COUNT(*)) For each pair of devices, count how many attributes they share using GROUP BY.

Filter by Threshold (WHERE SharedAttributeCount >= 2) Retain only the device pairs that share at least the specified number of attributes.

Example Output:
For the given data, the output could be:

DeviceA    DeviceB    SharedAttributeCount
Device1    Device2    3
Device1    Device3    2
Device1    Device4    3
Device2    Device4    3
This approach is scalable and works well for small to medium datasets. For large datasets, consider optimizing with indexes or precomputing results (materialized views).

*/
-- Step 1: Create a Devices table
CREATE TABLE Devices (
    DeviceID VARCHAR(50),
    Attribute VARCHAR(50)
);

-- Step 2: Insert example data into the table
INSERT INTO Devices (DeviceID, Attribute) VALUES
('Device1', 'WiFi'),
('Device1', 'Bluetooth'),
('Device1', 'GPS'),
('Device2', 'Bluetooth'),
('Device2', 'WiFi'),
('Device2', 'GPS'),
('Device3', 'WiFi'),
('Device3', 'Bluetooth'),
('Device4', 'GPS'),
('Device4', 'WiFi'),
('Device4', 'Bluetooth'),
('Device4', 'NFC');

-- Step 3: Query to find similar devices
WITH SharedAttributes AS (
    SELECT
        d1.DeviceID AS DeviceA,
        d2.DeviceID AS DeviceB,
        COUNT(*) AS SharedAttributeCount
    FROM
        Devices d1
    INNER JOIN
        Devices d2
    ON
        d1.Attribute = d2.Attribute AND d1.DeviceID < d2.DeviceID
    GROUP BY
        d1.DeviceID, d2.DeviceID
),
FilteredResults AS (
    SELECT
        DeviceA,
        DeviceB,
        SharedAttributeCount
    FROM
        SharedAttributes
    WHERE
        SharedAttributeCount >= 2 -- Set your similarity threshold here
)
SELECT
    DeviceA,
    DeviceB,
    SharedAttributeCount
FROM
    FilteredResults;
