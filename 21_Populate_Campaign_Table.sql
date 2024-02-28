
USE DBIAggregateData
GO

insert into [Campaign] (CampaignID, CampaignDesc, MissionCode, CampaignDate)
select *
from DBI_2022_FallMailing..Campaign

--select * from Campaign


