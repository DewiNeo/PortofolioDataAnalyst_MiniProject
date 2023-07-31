USE Portofolio_DataAnalyst_DataClean

SELECT * FROM NashvilleHousingData

-- 	FILL NULL PropertyAdress BASED ON ParcelID
SELECT x.ParcelID, 
	x.PropertyAddress, 
	y.ParcelID, 
	y.PropertyAddress, 
	[FillAddress] = ISNULL(x.PropertyAddress,y.PropertyAddress)	 
FROM NashvilleHousingData x
JOIN NashvilleHousingData y
	ON x.ParcelID = y.ParcelID
	AND x.UniqueID != y.UniqueID
WHERE x.PropertyAddress IS NULL


UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
FROM NashvilleHousingData x
JOIN NashvilleHousingData y
	ON x.ParcelID = y.ParcelID
	AND x.UniqueID != y.UniqueID
WHERE x.PropertyAddress IS NULL


-- SPLIT UP THE PropertyAddress and OwnerAddress BECOME ADDRESS, CITY AND STATE [become more easy to read]
SELECT	PropertyAddress
FROM NashvilleHousingData

SELECT PropertyAddress,
	[SplitUp_Address] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	[SplitUp_City] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SplitUp_PropertyAddress VARCHAR(255),
	SplitUp_PropertyCity VARCHAR(255)

--ALTER TABLE NashvilleHousingData
--DROP COLUMN SplitUp_Address,
--	SplitUp_City

UPDATE NashvilleHousingData
SET SplitUp_PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	SplitUp_PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress,
	SplitUp_PropertyAddress,
	SplitUp_PropertyCity
FROM NashvilleHousingData


SELECT OwnerAddress
FROM NashvilleHousingData
				
SELECT OwnerAddress,
	--[OwnerAddress] = PARSENAME(OwnerAddress, 2)	-- PARSENAME READ FROM THE RIGHT, PARSENAME CONLD ONLY WORK WITH '.' 
	[SplitUp_OwnerAddress] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1)),
	[SplitUp_OwnerCity] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),2)),
	[SplitUp_OwnerState] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),3))
FROM NashvilleHousingData

SELECT OwnerAddress,
	--[OwnerAddress] = PARSENAME(OwnerAddress, 2)	-- PARSENAME READ FROM THE RIGHT, PARSENAME CONLD ONLY WORK WITH '.' 
	[SplitUp_OwnerAddress] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	[SplitUp_OwnerCity] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	[SplitUp_OwnerState] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD  SplitUp_OwnerAddress VARCHAR(255), 
	SplitUp_OwnerCity VARCHAR(255),
	SplitUp_OwnerState VARCHAR(255)

UPDATE NashvilleHousingData
SET [SplitUp_OwnerAddress] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),1)),
	[SplitUp_OwnerCity] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),2)),
	[SplitUp_OwnerState] = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'),3))


SELECT OwnerAddress,
	SplitUp_OwnerAddress,
	SplitUp_OwnerCity,
	SplitUp_OwnerState
FROM NashvilleHousingData



-- FIXING SALEDATE BECOME MORE EASY TO READ
SELECT SaleDate, 
	[SaleDateConvert] = CAST(SaleDate AS DATE)
FROM NashvilleHousingData

SELECT SaleDate, 
	[SaleDateConvert] = CONVERT(DATE, SaleDate)
FROM NashvilleHousingData

--Update NashvilleHousingData
--SET SaleDate =  CAST(SaleDate AS DATE)

--Update NashvilleHousingData
--SET SaleDate =  CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousingData
Add SaleDateConvert DATE;

Update NashvilleHousingData
SET SaleDateConvert =  CAST(SaleDate AS DATE)

Update NashvilleHousingData
SET SaleDateConvert =  CONVERT(DATE, SaleDate)

SELECT SaleDateConvert FROM NashvilleHousingData



-- TIDY UP SoldAsVacant FIELDS
SELECT DISTINCT SoldAsVacant,
	[Counter] = COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant			-- N=399, No=51403, Y=52, Yes 4623


SELECT DISTINCT
	CASE SoldAsVacant
		WHEN 'N' THEN 'No'
		WHEN 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET 
SoldAsVacant = 
CASE SoldAsVacant
	WHEN 'N' THEN 'No'
	WHEN 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

SELECT DISTINCT SoldAsVacant,
	[Counter] = COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant



-- CLEAN THE DUPLICATE DATA 
SELECT *, 
	RANK() OVER (
		PARTITION BY [ParcelID ], 
					 PropertyAddress,
					 SaleDateConvert, 
					 SalePrice, 
					 LegalReference 
					 ORDER BY UniqueID 
		) rankCounter
FROM NashvilleHousingData

WITH tryCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY [ParcelID ], 
					 PropertyAddress,
					 SaleDateConvert, 
					 SalePrice, 
					 LegalReference 
					 ORDER BY UniqueID 
		) rowCounter
FROM NashvilleHousingData
)
SELECT * FROM tryCTE
WHERE rowCounter > 1



-- DROP REDUNDANT TABLE [datetime, OwnerAddress, Property Address]
ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress, SaleDate,  OwnerAddress

SELECT * FROM NashvilleHousingData
