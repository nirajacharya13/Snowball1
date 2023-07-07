
select * from CovidPortfoliioP..NashvilleHousing
--where PropertyAddress is NULL

--Standardize the Date Format in SaleDate Field to YYYYMMDD 
--format and remove the time information (which looks redundant)

select SaleDate, convert(date,SaleDate) as ConvertedSalesDate
from CovidPortfoliioP..NashvilleHousing

ALTER Table CovidPortfoliioP..NashvilleHousing
Add ConvertedSalesDate date

update CovidPortfoliioP..NashvilleHousing
set ConvertedSalesDate=convert(date,SaleDate)

select SaleDate,ConvertedSalesDate from CovidPortfoliioP..NashvilleHousing

--Populate PropertyAddress data where NULL.

select [UniqueID ],ParcelID,LandUse, PropertyAddress 
from CovidPortfoliioP..NashvilleHousing
order by ParcelID

-- Using self join on to populate the address where NULL

select a.ParcelID, a.PropertyAddress, 
	   b.ParcelID, b.PropertyAddress,
	   isnull(a.PropertyAddress,b.PropertyAddress)
from CovidPortfoliioP..NashvilleHousing a
Join CovidPortfoliioP..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from CovidPortfoliioP..NashvilleHousing a
Join CovidPortfoliioP..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--Breaking out Address into Individual Columns 
--(Address, City, State) from PropertyAddress field
--using substring
select  PropertyAddress,
substring(PropertyAddress, 1 , charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',',PropertyAddress)+1,LEN(PropertyAddress	)) as City
from CovidPortfoliioP..NashvilleHousing

--Creating two new columns Address and City
ALTER Table CovidPortfoliioP..NashvilleHousing
Add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255)

--Update the above new columns
update CovidPortfoliioP..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1 , charindex(',',PropertyAddress)-1),
PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress)+1,LEN(PropertyAddress	))

select PropertyAddress, propertysplitaddress, propertysplitcity
from CovidPortfoliioP..NashvilleHousing

--Breaking out OwnerAddress into Individual Columns
--without using substring
select OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3)as Address,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
from CovidPortfoliioP..NashvilleHousing

--Creating threee new columns Address, City, and State
ALTER Table CovidPortfoliioP..NashvilleHousing
Add Address nvarchar(255), City nvarchar(255), State nvarchar(255)

--Update the above new columns
update CovidPortfoliioP..NashvilleHousing
set address = PARSENAME(replace(OwnerAddress,',','.'),3),
	city = PARSENAME(replace(OwnerAddress,',','.'),2),
	state = PARSENAME(replace(OwnerAddress,',','.'),1)

select OwnerAddress, address, city, state
from CovidPortfoliioP..NashvilleHousing

--Change Y and N to Yes and No in the "Sold as Vacant" field.

select (SoldAsVacant), count(SoldAsVacant)
from CovidPortfoliioP..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from CovidPortfoliioP..NashvilleHousing

update CovidPortfoliioP..NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

--Removing the duplicates using CTE, window functions
--It is not a standard practice to delete rows from db
--We can also use temp tables for it

With RowNumCte As (
select *, 
	ROW_NUMBER() over (
	partition by ParcelId,
				 PropertyAddress,
				 LegalReference,
				 SalePrice,
				 SaleDate
				 order by 
					UniqueId
					) row_num
from CovidPortfoliioP..NashvilleHousing)
select * from RowNumCte
where row_num > 1
order by PropertyAddress

--Removing the unused columns, this is for views
--not the best practice to remove columns from the raw data






