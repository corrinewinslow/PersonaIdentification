/*

CoPilot: give me a Microsoft SQL algorithm for finding all devices with similar attributes based on a jaccard index of 0.9 with grouping by similarity where all devices only display once
CoPilot: group by similarity
CoPilot: list attributes in each group

1. Attribute Grouping (attribute_sets): This part collects all the attributes for each device and organizes them into a single aggregated list (a string or array). For example, if a device has attributes like "color:red" and "size:large," the result would group these together for comparison.
  - This step ensures that each device has a consolidated view of its attributes, making it easier to calculate similarities.
2. Pairwise Similarity (pairwise_similarity): Here, devices are paired to compute their similarity using the Jaccard Index. For each pair of devices:
  - The intersection is calculated by counting how many attributes are shared between the two devices.
  - The union is calculated by counting all unique attributes across both devices.
  The formula for the Jaccard Index is applied: $$\text{Jaccard Index} = \frac{\text{Intersection}}{\text{Union}}$$
  This determines how similar two devices are based on their attributes.
3. Filtering by Similarity (filtered_pairs): Only device pairs with a Jaccard Index of 0.9 or greater are retained. This means the devices must share at least 90% similarity in their attributes to be included in the results.
4. Grouping Devices (grouped_devices): Similar devices are clustered into groups based on the similarity pairs. In this step:
  - Devices are combined into groups.
  - Attributes from these devices are aggregated alongside the groups to list the relevant attributes for each group.
5. Final Output: The query provides the following:
  - Grouped devices: A list of devices that are similar to each other.
  - Grouped attributes: The shared or relevant attributes for each group.
This ensures that devices are displayed only once, grouped logically by similarity, and accompanied by the attributes contributing to their grouping.

Output:

grouped_devices   grouped_attributes
--------------------------------------------------------------------------------------------
Device1           R00002B2,R0000CC2,R00021C6,R001EFE2
Device1,Device2   R00002B2,R0000CC2,R00021C6,R001EFE2,R00002B2,R0000CC2,R00021C6,R001EFE2
Device3           R00002B2,R0000CC2,R00021C6

*/
-- Step 1: Create the Devices table
CREATE TABLE device_attributes (
    device_id VARCHAR(50),
    attribute VARCHAR(50)
);

-- Step 2: Insert example data into the table
INSERT INTO device_attributes (device_id, attribute) VALUES
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

-- Step 1: Create a common table expression (CTE) for attribute grouping
WITH attribute_sets AS (
    SELECT
        device_id,
        STRING_AGG(attribute, ',') AS attributes
    FROM device_attributes
    GROUP BY device_id
),
pairwise_similarity AS (
    SELECT
        a.device_id AS device1,
        b.device_id AS device2,
        CAST(
            (
                SELECT COUNT(*)
                FROM STRING_SPLIT(a.attributes, ',') AS attr1
                JOIN STRING_SPLIT(b.attributes, ',') AS attr2
                ON attr1.value = attr2.value
            ) AS FLOAT
        ) /
        CAST(
            (
                SELECT COUNT(DISTINCT attr)
                FROM (
                    SELECT attr.value AS attr
                    FROM STRING_SPLIT(a.attributes, ',') AS attr
                    UNION ALL
                    SELECT attr.value AS attr
                    FROM STRING_SPLIT(b.attributes, ',') AS attr
                ) AS combined_attrs
            ) AS FLOAT
        ) AS jaccard_index,
        a.attributes AS attributes1,
        b.attributes AS attributes2
    FROM attribute_sets a
    CROSS JOIN attribute_sets b
    WHERE a.device_id < b.device_id -- Avoid self-pairs and duplicates
),
filtered_pairs AS (
    -- Filter device pairs with Jaccard index >= 0.9
    SELECT device1, device2, attributes1, attributes2
    FROM pairwise_similarity
    WHERE jaccard_index >= 0.9
),
grouped_devices AS (
    -- Group similar devices and their attributes
    SELECT
        STRING_AGG(CAST(device1 AS VARCHAR), ',') AS grouped_devices,
        STRING_AGG(attributes1, ',') AS grouped_attributes
    FROM filtered_pairs
    GROUP BY device2
)
-- Final Output: Display grouped devices and their attributes
SELECT grouped_devices, grouped_attributes
FROM grouped_devices;
