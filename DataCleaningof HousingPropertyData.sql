select *
from [dbo].[NationalHousing]

---updating the SaleDate Column
Select SaleDate, CONVERT(Date,SaleDate)
from [dbo].[NationalHousing]

Update [dbo].[NationalHousing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE dbo.NationalHousing
ADD SaleDateConverted DATE;

Update NationalHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

--populating property address
select *
from [dbo].[NationalHousing]
Where PropertyAddress is Null
Order By ParcelID

select ParcelID , PropertyAddress
From NationalHousing


Select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNUll(a.PropertyAddress, b.PropertyAddress)
From NationalHousing a
Join NationalHousing b On a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID and a.PropertyAddress is null 

update a
SET PropertyAddress= ISNUll(a.PropertyAddress,b.PropertyAddress)
FROM NationalHousing a
Join NationalHousing b On a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID and a.PropertyAddress is null 


--Breaking Out Address Into separate Columns


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) As Address2 
From NationalHousing

ALTER TABLE dbo.NationalHousing
ADD PropertySplitAddress Nvarchar(255);

Update NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.NationalHousing
ADD PropertySplitCityy Nvarchar(255);

Update NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) 

SELECt *
from NationalHousing

--------changing more
SELECt OwnerAddress
from NationalHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NationalHousing

ALTER TABLE dbo.NationalHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE dbo.NationalHousing
ADD OwnerSplitCity Nvarchar(255);

Update NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) 

ALTER TABLE dbo.NationalHousing
ADD OwnerSplitState Nvarchar(255);

Update NationalHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



---Standardising the SoldAsVacant Column

SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
from NationalHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No' 
	 Else SoldAsVacant
	 End
from NationalHousing

Update NationalHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No' 
	 Else SoldAsVacant
	 End


----Removing Duplicates

Select*, 
Row_Number() Over (
	Partition By ParcelID
		, PropertyAddress
		, SalePrice
		, SaleDate
		, LegalReference
		Order By
		UniqueID) row_num

From NationalHousing

--putting it in CTE to chose from 
With RowNumCTE As 
(
Select*, 
Row_Number() Over (
	Partition By ParcelID
		, PropertyAddress
		, SalePrice
		, SaleDate
		, LegalReference
		Order By
		UniqueID) row_num

From NationalHousing
)

Select *
From RowNumCTE
Where row_num > 1
order By PropertyAddress
-- deleting them
With RowNumCTE As 
(
Select*, 
Row_Number() Over (
	Partition By ParcelID
		, PropertyAddress
		, SalePrice
		, SaleDate
		, LegalReference
		Order By
		UniqueID) row_num

From NationalHousing
)

Delete 
From RowNumCTE
Where row_num > 1

---- Deleting Unused Columns

Select SaleDateConverted
From NationalHousing

Alter Table NationalHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NationalHousing
Drop Column SaleDate