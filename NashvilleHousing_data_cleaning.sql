-- Cleaning data in SQL queries
Select*
From SQL_data_cleaning.dbo.NashvilleHousing

-- Standardize Date Format
 

Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)

--Populate Property address data
Select *
From SQL_data_cleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- Join inside same tabel to populate adress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQL_data_cleaning.dbo.NashvilleHousing a
JOIN SQL_data_cleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress is null

	Update a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQL_data_cleaning.dbo.NashvilleHousing a
JOIN SQL_data_cleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
		Where a.PropertyAddress is null
	

	-- Breaking out Address into individual Columns (Address, City, State)

	Select PropertyAddress
From SQL_data_cleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

--Starts form the first value(1) and goes until the comma) -1 takes one step back and takes the comma out of the query and +1 loses also a comma
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
--CHARINDEX (',', PropertyAddress)
From SQL_data_cleaning.dbo.NashvilleHousing

--Creating two new columns, ALTER TABLE makes new column

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update SQL_data_cleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

Update SQL_data_cleaning.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM SQL_data_cleaning.dbo.NashvilleHousing


-- SEPREATE owner address, at first 1,2,3 it does backwards replacement, 3,2,1 makes it right way. 

SELECT OwnerAddress
FROM SQL_data_cleaning.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM SQL_data_cleaning.dbo.NashvilleHousing

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update SQL_data_cleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update SQL_data_cleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update SQL_data_cleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT *
FROM SQL_data_cleaning.dbo.NashvilleHousing


--Change Y and N Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldASVacant)
FROM SQL_data_cleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From SQL_data_cleaning.dbo.NashvilleHousing

Update SQL_data_cleaning.dbo.NashvilleHousing
SET SoldAsVacant=CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END


--Remove duplicates, creating CTE tabel, otherwise i couldnt do row_num<1
WITH RowNumCTE AS(
Select*,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				)as row_num

			From SQL_data_cleaning.dbo.NashvilleHousing
			--order by ParcelID
			)
			
Select*
From RowNumCTE
Where Row_num >1
Order by PropertyAddress

--- now we delete duplicates
WITH RowNumCTE AS(
Select*,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				)as row_num

			From SQL_data_cleaning.dbo.NashvilleHousing
			--order by ParcelID
			)
			
DELETE
From RowNumCTE
Where Row_num >1
--Order by PropertyAddress


--Delete unused columns, dont delete from original always from copy file

Select *
FROM SQL_data_cleaning.dbo.NashvilleHousing

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQL_data_cleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate