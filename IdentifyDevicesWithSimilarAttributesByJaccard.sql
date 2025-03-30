/*
CoPilot: give me a SQL algorithm for finding all devices with similar attributes based on a jaccard index of 1.0 with grouping by similarity and where all devices only display once

SQL algorithm to find all devices with similar attributes, grouped by similarity based on a Jaccard Index of 1.0 where each device appears only once in the results.

Explanation:
  1. Intersection CTE:
    - Calculates the number of shared attributes between pairs of devices (IntersectionSize).
    - A self-join is used to compare rows within the Devices table.
  2. UnionSize CTE:
    - Computes the total number of unique attributes across both devices (UnionSize).
    - Ensures uniqueness by subtracting duplicates (overlapping attributes) from the total.
  3. JaccardIndex CTE:
    - Calculates the Jaccard Index for each pair of devices: $$ Jaccard\ Index = \frac{\text{Intersection Size}}{\text{Union Size}} $$
    - Filters out device pairs with a similarity below 0.9.
  4. FilteredResults CTE:
    - Retains only those pairs of devices that meet or exceed the Jaccard Index threshold.
  5. DistinctGroups CTE:
    - Groups devices uniquely by assigning a Group Leader and a corresponding SimilarDevice.
    - This ensures that device pairs are not duplicated (e.g., (Device1, Device2) is treated the same as (Device2, Device1)).
  6. FinalGroups CTE:
    - Groups all devices under their respective "Group Leaders."
    - Uses STRING_AGG to create a comma-separated list of similar devices for each group.
    - Ensures that no device appears in multiple groups by excluding devices already listed as a "SimilarDevice."
  7. Final Query:
    - Outputs each GroupLeader with their list of SimilarDevices, ensuring every device is listed only once.

Example Output:
  For the given dataset and a Jaccard Index threshold of 0.9, the output might look like this:

  GroupLeader    SimilarDevices
  Device1        Device2, Device4
  Device3        Device5

  This ensures that each device is uniquely included in a similarity group and satisfies the Jaccard Index threshold of 1.0.

*/

-- Step 1: Create the Devices table
CREATE TABLE Devices (
    DeviceID VARCHAR(50),
    Attribute VARCHAR(50)
);

-- Step 2: Insert example data into the table
INSERT INTO Devices (DeviceID, Attribute) VALUES
('Device1', 'R00002B2'),
('Device1', 'R0000CC2'),
('Device1', 'R00021C6'),
('Device1', 'R001EFE2'),
('Device2', 'R00002B2'),
('Device2', 'R0000CC2'),
('Device2', 'R00021C6'),
('Device2', 'R001EFE2'),
('Device3', 'R00002B2'),
('Device3', 'R0000CC2'),
('Device3', 'R00021C6'),
('Device4', 'R00002B2'),
('Device4', 'R0000CC2'),
('Device4', 'R00021C6'),
('Device4', 'R001EFE2'),
('Device5', 'R0000CC2'),
('Device5', 'R00002B2'),
('Device5', 'R00021C6');

-- Step 3: Calculate Jaccard Index and group devices uniquely
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
        JaccardIndex >= 1 -- Filter for similarity threshold of 0.9
),
DistinctGroups AS (
    SELECT DISTINCT
        CASE
            WHEN DeviceA < DeviceB THEN DeviceA
            ELSE DeviceB
        END AS GroupLeader,
        CASE
            WHEN DeviceA < DeviceB THEN DeviceB
            ELSE DeviceA
        END AS SimilarDevice
    FROM
        FilteredResults
),
FinalGroups AS (
    SELECT
        GroupLeader,
        STRING_AGG(SimilarDevice, ', ') AS SimilarDevices
    FROM
        DistinctGroups
    WHERE GroupLeader NOT IN (
            SELECT SimilarDevice FROM DistinctGroups
        )
    GROUP BY
        GroupLeader
)
SELECT
    GroupLeader,
    SimilarDevices
FROM
    FinalGroups;
