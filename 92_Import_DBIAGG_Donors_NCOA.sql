
use DBIAggregateData
GO

Update donors set NCOA_StreetAddr=NULL, NCOA_StreetAddr2=NULL, NCOA_City=NULL, NCOA_StateCode=NULL, NCOA_Zip5=NULL
Update donors set
	donors.NCOA_StreetAddr=h.[Address Line 1],
	donors.NCOA_StreetAddr2=h.[Address Line 2],
	donors.NCOA_City=h.City,
	donors.NCOA_StateCode=h.State,
	donors.NCOA_Zip5=left(ltrim(h.[ZIP Code]),5)
from donors d
left join Staging..DBIAGG_Donors_NACSZ_20230308_Standardized h on d.MissionCode=h.MissionCode and d.DonorID=h.DonorID

/*

select top 10 * from Staging..DBIAGG_Donors_NACSZ_20230308_Standardized order by NEWID()
select top 1000 * from Donors order by NEWID()

select * from Staging..DBIAGG_Donors_NACSZ_20230308 where MissionCode='MMM' and DonorID=14392
select * from Staging..DBIAGG_Donors_NACSZ_20230308_Standardized where MissionCode='MMM' and DonorID=14392
select * from donors where MissionCode='MMM' and DonorID=14392

Update donors set NCOA_StreetAddr=NULL, NCOA_StreetAddr2=NULL, NCOA_City=NULL, NCOA_StateCode=NULL, NCOA_Zip5=NULL
Update donors set
	donors.NCOA_StreetAddr=case
		when h.[Address Line 2] IS NULL or h.[Address Line 2]='' then h.[Address Line 1]
		when h.[Address Line 2] IS NOT NULL and h.[Address Line 2]<>'' and
			(
			h.[Address Line 1] like '%# %' or h.[Address Line 1] like '%Apt %' or h.[Address Line 1] like '%Bldg %' or 
			h.[Address Line 1] like '%Box %' or h.[Address Line 1] like '%FL %' or h.[Address Line 1] like '%Lot %' or 
			h.[Address Line 1] like '%RM %' or h.[Address Line 1] like '%Spc %' or h.[Address Line 1] like '%Ste %' or
			h.[Address Line 1] like '%Trlr %' or h.[Address Line 1] like '%Unit %' or h.[Address Line 1] like '%PMB %'
			) then concat(h.[Address Line 2],' ',h.[Address Line 1])
		else h.[Address Line 1]
		end,
	donors.NCOA_StreetAddr2=case
		when h.[Address Line 2] IS NOT NULL and h.[Address Line 2]<>'' and
			(
			h.[Address Line 1] like '%# %' or h.[Address Line 1] like '%Apt %' or h.[Address Line 1] like '%Bldg %' or 
			h.[Address Line 1] like '%Box %' or h.[Address Line 1] like '%FL %' or h.[Address Line 1] like '%Lot %' or 
			h.[Address Line 1] like '%RM %' or h.[Address Line 1] like '%Spc %' or h.[Address Line 1] like '%Ste %' or
			h.[Address Line 1] like '%Trlr %' or h.[Address Line 1] like '%Unit %' or h.[Address Line 1] like '%PMB %'
			) then ''
		else h.[Address Line 2]
		end,
	donors.NCOA_City=h.City,
	donors.NCOA_StateCode=h.State,
	donors.NCOA_Zip5=left(ltrim(h.[ZIP Code]),5)
from donors d
left join Staging..DBIAGG_Donors_NACSZ_20230308_Standardized h on d.MissionCode=h.MissionCode and d.DonorID=h.DonorID

select * from Staging..DBIAGG_Donors_NACSZ_20230308_Standardized where [Address Line 2] IS NOT NULL and [Address Line 2]<>'' order by [Address Line 1]
select * from Staging..DBIAGG_Donors_NACSZ_20230308_Standardized where [Address Line 2] IS NOT NULL and [Address Line 2]<>'' order by [Address Line 2]

Update donors set donors.HouseholdHash=h.HouseholdHash
from donors d
left join Staging..DBIAGG_Donors_NACSZ_20230227_out h on d.MissionCode=h.MissionCode and d.DonorID=h.DonorID
--left join Staging..DBIAGG_Donors_NACSZ s on d.MissionCode=s.MissionCode and d.DonorID=s.DonorID
--left join Staging..DBIAGG_Donors_NACSZ_20230227_out h on s.UniqueID=h.UniqueID

*/

