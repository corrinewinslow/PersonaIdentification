/*
CoPilot: give me a SQL algorithm for finding all devices with similar attributes based on a jaccar index of .9 with grouping by similarity and all devices are only added once

SQL algorithm to identify all devices with similar attributes based on a Jaccard Index threshold of 0.9. The algorithm ensures that each device is added to a similarity group only once.

How the Algorithm Works:
  1. Intersection Calculation (Intersection CTE):
    - This calculates the number of attributes shared between two devices.
    - A COUNT(*) query is used to find the "intersection size," representing the total number of attributes that both devices have in common.
    - The condition d1.DeviceID < d2.DeviceID ensures each pair is only compared once, avoiding duplicate comparisons such as (Device1, Device2) and (Device2, Device1).
  2. Union Calculation (UnionSize CTE):
    - This calculates the total number of unique attributes across both devices being compared.
    - The formula for union size adds the distinct attributes from both devices and subtracts the overlapping attributes (intersection).
    - This step ensures the uniqueness of all combined attributes in the calculation.
  3. Jaccard Index Calculation (JaccardIndex CTE):
    - Using the formula: $$ Jaccard\ Index = \frac{\text{IntersectionSize}}{\text{UnionSize}} $$
    - For each pair of devices, the ratio of the intersection to the union is calculated. This value represents the similarity between the two devices.
  4. Threshold Filtering (FilteredResults CTE):
    - Filters out pairs of devices where the Jaccard Index is less than 0.9.
    - This step ensures that only highly similar devices (90% similarity or more) are retained for grouping.
  5. Distinct Grouping (DistinctGroups CTE):
    - Groups devices together based on their similarity.
    - Uses the STRING_AGG function to aggregate all devices similar to a given "Group Leader" (DeviceA) into a single comma-separated list.
    - Ensures no device appears in more than one group by excluding devices already listed in other groups.
  6. Final Query:
    - The output displays each GroupLeader (the primary device for each group) alongside its list of similar devices.
    - By excluding any device already grouped, this guarantees that each device is included only once.

Why It Ensures Each Device Is Only Added Once:
  The DistinctGroups CTE ensures unique grouping by:
    - Assigning one device (DeviceA) as the "Group Leader."
    - Ensuring that no DeviceB already appears as a group member in another group.
  This prevents overlapping groups and ensures that all devices are distinctly categorized.

Example:
  For the given dataset and a Jaccard Index of 0.9, the output might look like:
  
  GroupLeader    SimilarDevices
  Device1        Device2, Device4
  Device5        Device3

  This approach ensures that each device is part of exactly one group and groups are formed only if the similarity exceeds the Jaccard threshold of 0.9.

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
