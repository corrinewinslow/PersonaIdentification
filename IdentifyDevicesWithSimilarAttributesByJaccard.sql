/*
CoPilot: give me a SQL algorithm for finding all devices with similar attributes based on a jaccard index of .9 with grouping by similarity

SQL algorithm to find all devices with similar attributes based on a Jaccard Index threshold of 0.9, and group them by similarity.

Steps:
  1. Create the Devices Table Store each device and its associated attributes in the Devices table.
  2. Self-Join the Table Compare attributes between device pairs by performing a self-join.
  3. Calculate Intersection and Union of Attributes
    - Calculate the intersection size (shared attributes).
    - Calculate the union size (unique attributes across both devices).
  4. Calculate Jaccard Index Use the formula: $$ Jaccard\ Index = \frac{|Intersection|}{|Union|} $$ Filter device pairs where the Jaccard Index meets or exceeds 0.9.
  5. Group Similar Devices Consolidate all devices into groups based on similarity.

Explanation:
  1. Intersection (Intersection CTE): Calculates the number of shared attributes between pairs of devices.
  2. Union (UnionSize CTE): Calculates the union size by summing the unique attributes from both devices and subtracting duplicates.
  3. Jaccard Index (JaccardIndex CTE): Divides the intersection size by the union size, producing a similarity score between 0 and 1.
  4. FilteredResults: Filters device pairs where the Jaccard Index is at least 0.9.
  5. Groups: Uses STRING_AGG to group all similar devices for each DeviceA (GroupLeader).
  6. Final Output: Displays each DeviceA alongside its similar devices.

Example Output:
  For the provided data and a Jaccard Index threshold of 0.9, the output might look like this:
  
  GroupLeader    SimilarDevices
  Device1        Device2, Device4
  Device2        Device1, Device4
  Device4        Device1, Device2

This query is efficient for grouping devices based on a high similarity threshold.

*/

-- Step 1: Create the Devices table
CREATE TABLE Devices (
    DeviceID VARCHAR(50),
    Attribute VARCHAR(50)
);

-- Step 2: Insert example data into the table
INSERT INTO Devices (DeviceID, Attribute) VALUES
('Device1', 'WiFi'),
('Device1', 'Bluetooth'),
('Device1', 'GPS'),
('Device1', 'NFC'),
('Device2', 'WiFi'),
('Device2', 'Bluetooth'),
('Device2', 'GPS'),
('Device2', 'NFC'),
('Device3', 'WiFi'),
('Device3', 'Bluetooth'),
('Device3', 'GPS'),
('Device4', 'WiFi'),
('Device4', 'Bluetooth'),
('Device4', 'GPS'),
('Device4', 'NFC'),
('Device5', 'Bluetooth'),
('Device5', 'WiFi'),
('Device5', 'GPS');

-- Step 3: Calculate Jaccard Index and group by similarity
WITH Intersection AS (
    SELECT
        d1.DeviceID AS DeviceA,
        d2.DeviceID AS DeviceB,
        COUNT(*) AS IntersectionSize
    FROM
        Devices d1
    INNER JOIN
        Devices d2
    ON
        d1.Attribute = d2.Attribute AND d1.DeviceID < d2.DeviceID
    GROUP BY
        d1.DeviceID, d2.DeviceID
),
UnionSize AS (
    SELECT
        d1.DeviceID AS DeviceA,
        d2.DeviceID AS DeviceB,
        COUNT(DISTINCT d1.Attribute) + COUNT(DISTINCT d2.Attribute) -
        COUNT(DISTINCT CASE WHEN d1.Attribute = d2.Attribute THEN d1.Attribute END) AS UnionSize
    FROM
        Devices d1
    INNER JOIN
        Devices d2
    ON
        d1.DeviceID < d2.DeviceID
    GROUP BY
        d1.DeviceID, d2.DeviceID
),
JaccardIndex AS (
    SELECT
        i.DeviceA,
        i.DeviceB,
        i.IntersectionSize,
        u.UnionSize,
        CAST(i.IntersectionSize AS FLOAT) / CAST(u.UnionSize AS FLOAT) AS JaccardIndex
    FROM
        Intersection i
    INNER JOIN
        UnionSize u
    ON
        i.DeviceA = u.DeviceA AND i.DeviceB = u.DeviceB
),
FilteredResults AS (
    SELECT
        DeviceA,
        DeviceB
    FROM
        JaccardIndex
    WHERE
        JaccardIndex >= 0.9 -- Set your threshold here
),
Groups AS (
    SELECT
        DeviceA,
        STRING_AGG(DeviceB, ', ') AS SimilarDevices
    FROM
        FilteredResults
    GROUP BY
        DeviceA
)
SELECT
    DeviceA AS GroupLeader,
    SimilarDevices
FROM
    Groups;
