/* 
Data Cleaning
*/


-- Standardize Date Format

select SaleDate, convert(Date,SaleDate)
from NasvilleHousing

alter table NasvilleHousing
add SaleDateConverted Date


update NasvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

select SaleDate,SaleDateConverted from NasvilleHousing

select * from NasvilleHousing


-- Populate the Property Address

select * from NasvilleHousing
order by ParcelID

select a.ParcelId,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousing a
Join NasvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NasvilleHousing a
Join NasvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns(Address,City,State)

select PropertyAddress 
from NasvilleHousing

select Left(PropertyAddress,charindex(',',PropertyAddress)-1),Right(PropertyAddress,len(PropertyAddress)-charindex(',',PropertyAddress))
from NasvilleHousing



alter table NasvilleHousing
add PropertyAddressHouse nvarchar(255)

update NasvilleHousing
set PropertyAddressHouse = Left(PropertyAddress,charindex(',',PropertyAddress)-1)

alter table NasvilleHousing
add PropertyAddressCity nvarchar(255)

update NasvilleHousing
set PropertyAddressCity = Right(PropertyAddress,len(PropertyAddress)-charindex(',',PropertyAddress))

Select * from NasvilleHousing


-- Similar above changes to owner property

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1) from NasvilleHousing


alter table NasvilleHousing
add OwnerAddressHouse nvarchar(255)

update NasvilleHousing
set OwnerAddressHouse = parsename(replace(OwnerAddress,',','.'),3)

alter table NasvilleHousing
add OwnerAddressCity nvarchar(255)

update NasvilleHousing
set OwnerAddressCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NasvilleHousing
add OwnerAddressState nvarchar(255)

update NasvilleHousing
set OwnerAddressState = parsename(replace(OwnerAddress,',','.'),1)

Select * from NasvilleHousing 

-- Change Y and N to Yes and No respectively in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from NasvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant end
from NasvilleHousing


update NasvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant end
                   from NasvilleHousing


-- Remove Duplicates
with RowNumCTE as (
select *,
ROW_NUMBER() over(

		partition by
						ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
		order by UniqueID
		) row_num
from NasvilleHousing )
Delete from RowNumCTE
where row_num>1
-- order by PropertyAddress



-- Delete Unused Columns

alter table NasvilleHousing
drop column OwnerAddress,PropertyAddress,TaxDistrict,SaleDate

select * from NasvilleHousing