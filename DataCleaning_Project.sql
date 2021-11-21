---DATA SOURCE; Alex the analyst on github; NashvilleHousing
---import data
SELECT * from NashvilleHousing
---select distinct all table
--check null values
--get to know your table before calculations

--Standardize date format by converting it to just date
select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing


SELECT * from NashvilleHousing

--NOW WE UPDATE IT INTO THE TABLE
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--APPARENTLY it is not updating so we will use alter table by adding a new column
---ALter TABLE NashvilleHousing
---SET SaleDateConverted = CONVERT(Date, SaleDate)

ALTER TABLE Nashvillehousing
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---see if it worked
select saledateconverted
from NashvilleHousing

--There are Null values. 
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

---DOING A SELF JOIN
select *
from NashvilleHousing as a
join  NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]

-------
select a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing as a
join  NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

----now we update our query
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing as a
join  NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


---BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (address, city, state) kinda like spliting
SELECT PropertyAddress
FROM NashvilleHousing

--since there is no delimiter, we will be using a substring nad character index
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

-------------------------------------updating tables
ALTER TABLE Nashvillehousing
add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashvillehousing
add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--ANOTHER WAY TO SPLIT IT IS BY:
--using Parsename; parsename only sees periods(.) replace (,) to a period
--- parsename does things backwards tho

select OwnerAddress
from  NashvilleHousing
--TO seperate this, 
select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-------------------------------------updating tables
ALTER TABLE Nashvillehousing
add OwnwerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnwerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashvillehousing
add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashvillehousing
add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

----selecting distinct
Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
Order by SoldAsVacant

----so now we will replace
select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'YES'
when SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
from NashvilleHousing

---updating table this time, we are just updating not ading a new column
Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
when SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

----DELEING DUPLICATES AND IN ORDER TO DO THAT, WE WILL CREATE CTE= TEMP TABLE
---find duplicates with row_ find columns should have unique values

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) as row_num
from NashvilleHousing
order by ParcelID

---put it in a CTE
WITH RowNumCTE as(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) as row_num
from NashvilleHousing)
SELECT *
FROM RowNumCTE
where  row_num > 1
order by PropertyAddress

---now we delete Duplicate rows
WITH RowNumCTE as(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) as row_num
from NashvilleHousing)
DELETE
FROM RowNumCTE
where  row_num > 1

---DELETING UNSUED COLUMNS
--its better to creat views and add columns you want than
---deleting columns from your raw data
--- since this is data cleaning, i gues we could justb delete the columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, TaxDistrict, PropertyAddress