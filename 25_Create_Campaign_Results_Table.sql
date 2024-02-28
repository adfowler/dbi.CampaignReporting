
USE DBIAggregateData
GO

--=================================================================
-- create CampaignResults table with all the possible combinations
-- of the following fields from CampaignHistory & related tables
/*
CampaignID
Zip5
State
CityMixedCase
CountyMixedCase
SegmentCode
MailedVolume
MissionCode
TouchDescription
MailDate
Wave
SegmentCode
SegmentDescription

Donors
Gifts
Amount
NewDonors
MaxGift

AttributionType (Direct, Matchback, Combined)
*/
--=================================================================

drop table if exists #CampaignResults
select
	-- from CampaignHistory table
	ch.ZIP5,
	-- from Zips..Zips table
	z.State,
	z.CityMixedCase,
	z.CountyMixedCase,
	-- from Campaign table
	c.CampaignID, c.MissionCode,
	-- from Touch table
	t.TouchID, t.Wave, MailDate=cast(t.TouchDate as date), t.TouchDesc, AppealCode=t.CRE,
	-- from Segments table
	s.Segment_Code, s.Segment_Description, s.List_Type,
	MailedVolume=count(*), Cost=count(*)*max(cost.TouchCost),
	Donors=cast(0 as int), Gifts=cast(0 as int), Amount=cast(0 as money), NewDonors=cast(0 as int), MaxGift=cast(0 as money)
	--,ch.SegmentCode 'ch_seg'
into #CampaignResults
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on ch.CampaignID=c.CampaignID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join CampaignCosts cost on t.CampaignID=cost.CampaignID and t.Wave=cost.Wave and s.List_Type=cost.Version
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P' 
where CH.CampaignID in (select CampaignID from DBI_2023_FallMailing..Campaign)
group by
	-- from CampaignHistory table
	ch.ZIP5,
	-- from Zips..Zips table
	z.State,
	z.CityMixedCase,
	z.CountyMixedCase,
	-- from Campaign table
	c.CampaignID, c.MissionCode,
	-- from Touch table
	t.TouchID, t.Wave, cast(t.TouchDate as date), t.TouchDesc, t.CRE,
	-- from Segments table
	s.Segment_Code, s.Segment_Description, s.List_Type
	--,ch.SegmentCode
	



--drop table if exists CampaignResults

delete from CampaignResults where CampaignID in (select CampaignID from DBI_2023_FallMailing..Campaign)

insert into CampaignResults select *, AttributionType='Direct' from #CampaignResults
insert into CampaignResults select *, AttributionType='Matchback' from #CampaignResults
insert into CampaignResults select *, AttributionType='Combined' from #CampaignResults


/*
select * from #CampaignResults

select count(*) from CampaignHistory
select sum(MailedVolume) from CampaignResults where AttributionType='Direct'
*/

--=================================================================
-- create table of valid appeal codes for each touch
--=================================================================

--select * from Touch

--drop table if exists Responders_AppealCodes

INSERT INTO Responders_AppealCodes
SELECT distinct t.CampaignID, t.TouchID, c.MissionCode, AppealCode=t.CRE
FROM Touch t
left join Campaign c on t.CampaignID=c.CampaignID
WHERE t.CampaignID NOT IN (SELECT CampaignID FROM Responders_AppealCodes)

--=================================================================
-- Update touch descriptions
--=================================================================
UPDATE CampaignResults
SET TouchDesc = t.touchdesc
FROM CampaignResults cr INNER JOIN Touch t
  on cr.CampaignID = t.CampaignID and
     cr.TouchID = t.TouchID