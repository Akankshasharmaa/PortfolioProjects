SELECT * 
FROM public.nashvillehousingdata;

-- 1.Standarize Date Formate

SELECT saledate, SaleDateConverted
FROM public.nashvillehousingdata;

-- First, converting date format from 'April 29,2004' to '2004-04-2004' 
Update nashvillehousingdata
SET saledate = to_char(to_date(saledate, 'Month-DD-YYYY'),'YYYY-MM-DD')
-- Adding new col
ALTER TABLE nashvillehousingdata
ADD SaleDateConverted Date;
-- Changing Data type from char to date.
Update nashvillehousingdata
SET SaleDateConverted = to_date(saledate, 'YYYY-MM-DD');

--------------------------------------------------------------
-- 2.Populate Property Address data
SELECT *
FROM public.nashvillehousingdata
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM public.nashvillehousingdata as a
JOIN public.nashvillehousingdata as b
	ON a.parcelid = b.parcelid		-- parcel id is same
	AND a.uniqueid <> b.uniqueid	-- but unique id is different
WHERE a.propertyaddress IS NULL

UPDATE nashvillehousingdata
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress) -- can also add string if no other address 'No Adrress' instead of b.property
FROM public.nashvillehousingdata as a
JOIN public.nashvillehousingdata as b
	ON a.parcelid = b.parcelid		
	AND a.uniqueid <> b.uniqueid	
WHERE a.propertyaddress IS NULL

---------------------------------------------------------
-- 3. 	Breaking out Address into individual columns (Address, City, State)

SELECT propertyaddress
FROM public.nashvillehousingdata;

SELECT
	SUBSTRING(propertyaddress from 1 for(position(',' in propertyaddress) - 1)) as Address,
	SUBSTRING(propertyaddress from(position(',' in propertyaddress)+1) for(LENGTH(propertyaddress))) AS City
FROM public.nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD property_split_address varchar;

UPDATE nashvillehousingdata
SET property_split_address = SUBSTRING(propertyaddress from 1 for(position(',' in propertyaddress) - 1))

ALTER TABLE nashvillehousingdata
ADD property_split_city varchar;

UPDATE nashvillehousingdata
SET property_split_city = SUBSTRING(propertyaddress from(position(',' in propertyaddress)+1) for(LENGTH(propertyaddress)))

SELECT *
FROM public.nashvillehousingdata;

-- Spliting Owner's address into address, city and state
SELECT split_part(owneraddress, ',', 1) as address,
split_part(owneraddress, ',', 2) as city,
split_part(owneraddress, ',', 3) as state
FROM public.nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD owner_split_address varchar;

UPDATE nashvillehousingdata
SET owner_split_address = split_part(owneraddress, ',', 1)

ALTER TABLE nashvillehousingdata
ADD owner_split_city varchar;

UPDATE nashvillehousingdata
SET owner_split_city = split_part(owneraddress, ',', 2)

ALTER TABLE nashvillehousingdata
ADD owner_split_state varchar;

UPDATE nashvillehousingdata
SET owner_split_state = split_part(owneraddress, ',', 3)


SELECT *
FROM public.nashvillehousingdata;

-----------------------------
-- change Y and N to yes and no in soldasvacant field

SELECT distinct soldasvacant, count(soldasvacant) as total
FROM public.nashvillehousingdata
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant,
case 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
FROM public.nashvillehousingdata;

UPDATE nashvillehousingdata
SET soldasvacant = case 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end

----------------------------
-- Remove Duplicates
--- Going to use CTE and using window functions to find where are duplicate values
SELECT *,
row_number() over (
PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			ORDER BY uniqueid) as row_num
FROM public.nashvillehousingdata
-- WHERE row_num > 1 won't work because it's a window function, therefore we use CTE
ORDER BY parcelid;

-- Deleting the duplicates
WITH rownumcte as(
SELECT uniqueid from (
	SELECT uniqueid,
	row_number() over (
	PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
	ORDER BY uniqueid) as row_num
	FROM public.nashvillehousingdata
	) s 
WHERE row_num > 1
)
DELETE FROM nashvillehousingdata
WHERE uniqueid IN (SELECT * FROM rownumcte)

-- check if the query worked
WITH rownumcte as(
SELECT *,
	row_number() over (
	PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
	ORDER BY uniqueid) as row_num
FROM public.nashvillehousingdata
)
SELECT * FROM rownumcte
WHERE row_num > 1


------------------------------------
-- Deleting unused columns
SELECT *
FROM public.nashvillehousingdata;

ALTER TABLE public.nashvillehousingdata
DROP COLUMN owneraddress, 
DROP COLUMN propertyaddress, 
DROP COLUMN taxdistrict;

ALTER TABLE public.nashvillehousingdata
DROP COLUMN saledate 