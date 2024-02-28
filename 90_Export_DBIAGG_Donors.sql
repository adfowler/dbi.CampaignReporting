
use DBIAggregateData
GO

drop table IF EXISTS Staging..DBIAGG_Donors_NCOA_NACSZ_20230309
select UniqueID=identity(int, 1, 1), MissionCode, DonorID, FirstName, LastName, NCOA_StreetAddr, NCOA_StreetAddr2, NCOA_City, NCOA_StateCode, NCOA_Zip5
into Staging..DBIAGG_Donors_NCOA_NACSZ_20230309
from [DBIAggregateData].[dbo].[Donors]

--select top 1000 * from Staging..DBIAGG_Donors_NACSZ order by NEWID()

--select count(*), count(distinct UniqueID) from Staging..DBIAGG_Donors_NACSZ

--select MissionCode, count(*), count(distinct DonorID) from DBIAggregateData..Donors group by MissionCode order by 1




