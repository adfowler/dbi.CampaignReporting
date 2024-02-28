
use DBIAggregateData
GO

Update Staging..DBIAGG_Donors_NACSZ_20230227_out set HouseholdHash=replace(replace(REPLACE(HouseholdHash,'"',''),'[',''),']','')

Update donors set donors.HouseholdHash=h.HouseholdHash
from donors d
left join Staging..DBIAGG_Donors_NACSZ_20230227_out h on d.MissionCode=h.MissionCode and d.DonorID=h.DonorID
--left join Staging..DBIAGG_Donors_NACSZ s on d.MissionCode=s.MissionCode and d.DonorID=s.DonorID
--left join Staging..DBIAGG_Donors_NACSZ_20230227_out h on s.UniqueID=h.UniqueID

Update Staging..DBIAGG_Donors_NCOA_NACSZ_20230309_Hash set HouseholdHash=replace(replace(REPLACE(HouseholdHash,'"',''),'[',''),']','')

Update donors set donors.NCOA_HouseholdHash=h.HouseholdHash
from donors d
left join Staging..DBIAGG_Donors_NCOA_NACSZ_20230309_Hash h on d.MissionCode=h.MissionCode and d.DonorID=h.DonorID

/*
select top 1000 * from Staging..DBIAGG_Donors_NACSZ_20230227_out order by NEWID()
select top 1000 * from donors order by NEWID()

select * from Staging..DBIAGG_Donors_NACSZ
where UniqueID in (select UniqueID from Staging..DBIAGG_Donors_NACSZ_20230227_out where HouseholdHash IS NULL or HouseholdHash='')

-- select top 10 CH_ID, HouseholdHash from CampaignHistory order by NEWID()

drop table if exists #tmp
select CH_ID, orig_hash=HouseholdHash, clean_hash=replace(replace(REPLACE(HouseholdHash,'"',''),'[',''),']',''),
	hash1=cast(NULL as varchar(200)), hash2=cast(NULL as varchar(200))
into #tmp
from CampaignHistory

UPDATE #tmp set hash1=left(clean_hash,64), hash2=right(clean_hash,64)

select top 10 *, comma=patindex('%,%',clean_hash) from #tmp

select patindex('%,%',clean_hash), count(*) from #tmp group by patindex('%,%',clean_hash)

select top 10 * from #tmp where hash1<>hash2

select top 10 orig_hash, substring(orig_hash,3,64) from #tmp

-- F5AF8672E68B0865ABE101B322CE5AD5E1CC5067F710F337113F1E31CACC93DD,F5AF8672E68B0865ABE101B322CE5AD5E1CC5067F710F337113F1E31CACC93DD
*/

