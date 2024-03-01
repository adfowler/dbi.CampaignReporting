
USE DBIAggregateData
GO

--=================================================================
-- create table of gifts that were responses to campaigns
--    - #Responders - any gift with appealcode match to a touch
--    - #Responders_MB - Matchback matching gifts by MissionCode,
--      Householdhash, specific AppealCodes, giftdate betweeen
--      inhome date and Response Days, & exclude gifts>=$1,000
--=================================================================

--delete Touch where TouchID like '%A%' or TouchID like '%B%' or TouchID like '%C%'

-- direct appeal code match
drop table if exists #Responders
select ra.CampaignID,
	g.MissionCode,
	g.DonorID, g.GiftID, g.GiftDate, g.AppealCode, SegmentCode=coalesce(ltrim(g.SegmentCode),''), g.Amount,
	d.FirstName, d.LastName, d.Salutation, StreetAddr=d.NCOA_StreetAddr, StreetAddr2=d.StreetAddr, City=d.City, StateCode=d.StateCode, Zip5=coalesce(ltrim(d.zip5),''),
	ZIP_County=z.CountyMixedCase,
	New_Donor=cast(0 as int),
	TouchID
into #Responders
from Gifts g
left join Donors d on g.MissionCode=d.MissionCode and g.DonorID=d.DonorID
left join Zips..Zips z on left(d.ZIP5,5)=z.ZipCode and PrimaryRecord='P'
inner join Responders_AppealCodes ra on g.MissionCode=ra.MissionCode and g.AppealCode=ra.AppealCode
where g.Amount>0
and ra.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)



-- BRM sends the appeal code in the campaigncode field with the segment code appended to it
insert into #Responders
select ra.CampaignID,
	g.MissionCode,
	g.DonorID, g.GiftID, g.GiftDate, ra.AppealCode, SegmentCode=CASE 
														WHEN ra.AppealCode IN ('Q2209', 'Q2211', 'Q2309') THEN SUBSTRING(CampaignCode, 6, 99) 
														WHEN ra.AppealCode IN ('Q23111', 'Q23112')THEN SUBSTRING(CampaignCode, 7, 99) 
													  END, g.Amount,
	d.FirstName, d.LastName, d.Salutation, StreetAddr=d.NCOA_StreetAddr, StreetAddr2=d.StreetAddr, City=d.City, StateCode=d.StateCode, Zip5=coalesce(ltrim(d.zip5),''),
	ZIP_County=z.CountyMixedCase,
	New_Donor=cast(0 as int),
	TouchID
from Gifts g
left join Donors d on g.MissionCode=d.MissionCode and g.DonorID=d.DonorID
left join Zips..Zips z on left(d.ZIP5,5)=z.ZipCode and PrimaryRecord='P'
inner join Responders_AppealCodes ra on g.MissionCode=ra.MissionCode 
where g.Amount>0
and g.MissionCode = 'BRM'
and ra.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
and g.CampaignCode like ra.AppealCode + '%'

-- BSM doesn't send segment code on the gift. this effects mail volume and segment rollups
--update on donorid
UPDATE r
SET r.SegmentCode = ch.SegmentCode
FROM #Responders r INNER JOIN CampaignHistory ch
  on r.CampaignID = ch.CampaignID
  and r.AppealCode = ch.AppealCode
  and r.DonorID = ch.donor_id
  and r.TouchID = ch.TouchID
WHERE r.MissionCode = 'BSM'
  AND r.SegmentCode = ''

--update on householdhash
UPDATE r
SET r.SegmentCode = ch.SegmentCode
FROM #Responders r 
inner join Donors d  on r.DonorID = d.DonorID and r.MissionCode = d.MissionCode
inner join CampaignHistory ch on  
	  r.CampaignID = ch.CampaignID
  and r.AppealCode = ch.AppealCode
  and ch.HouseholdHash = d.NCOA_HouseholdHash
  and r.TouchID = ch.TouchID
WHERE r.MissionCode= 'BSM'
  AND r.SegmentCode = ''





-- ROH sends the appeal code with an '_' in the middle of it plus some other stuff at the end (segment code?)
insert into #Responders
select ra.CampaignID,
	g.MissionCode,
	g.DonorID, g.GiftID, g.GiftDate, ra.AppealCode, SegmentCode=CASE WHEN ra.AppealCode IN ('23D101', '23D102', '23D103') THEN SUBSTRING(g.AppealCode, 8, 99)
																	 WHEN ra.AppealCode = '23D121' THEN REPLACE(left(AppealDesc, charindex(' ', AppealDesc) - 1), '23D121','') end, g.Amount,
	d.FirstName, d.LastName, d.Salutation, StreetAddr=d.NCOA_StreetAddr, StreetAddr2=d.StreetAddr, City=d.City, StateCode=d.StateCode, Zip5=coalesce(ltrim(d.zip5),''),
	ZIP_County=z.CountyMixedCase,
	New_Donor=cast(0 as int),
	TouchID
from Gifts g
left join Donors d on g.MissionCode=d.MissionCode and g.DonorID=d.DonorID
left join Zips..Zips z on left(d.ZIP5,5)=z.ZipCode and PrimaryRecord='P'
inner join Responders_AppealCodes ra on g.MissionCode=ra.MissionCode 
where g.Amount>0
and g.MissionCode = 'ROH'
and ra.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
and REPLACE(g.AppealCode, '_', '') like ra.AppealCode + '%'
and g.GiftDate >= '2023-10-01'

--SELECT * FROM Responders_AppealCodes
--SELECT * FROM DBI_2023_FallMailing..Campaign
--SELECT * FROM #Responders where missioncode = 'roh' and city = 'Dellroy'


-- temp code to grab mailed segment codes for BSM that Jon matched since BSM DB does not have segment code in DB
UPDATE #Responders
set #Responders.SegmentCode=coalesce(bsm_seg.Mailed_Segment_Code,'')
from #Responders
inner join z_BSM_temp_Gift_Segments bsm_seg on #Responders.GiftID=bsm_seg.gift_id and #Responders.MissionCode='BSM  '

--select MissionCode, AppealCode, count(*) from #Responders group by MissionCode, AppealCode order by MissionCode, AppealCode
--select * from #Responders_AppealCodes order by MissionCode, AppealCode
--select * from gifts where AppealCode='Q2210' and MissionCode='BSM'


-- Pass2
DROP TABLE IF EXISTS #Responders_MB

-- BRM Uses CampaignCode
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
into #Responders_MB
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.CampaignCode=mb.AppealCode
where  g.MissionCode = 'BRM'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1

-- null campaign code
insert into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
--inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.CampaignCode=mb.AppealCode
where  g.MissionCode = 'BRM'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	--and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	--and ch.seed<>1
	and g.CampaignCode IS NULL

-- BRM address matches
insert into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.HouseholdHash=d.NCOA_HouseholdHash
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.CampaignCode=mb.AppealCode
where  g.MissionCode = 'BRM'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders_MB)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1


-- HHS. Need to go the the HHS database to pull motive_code
INSERT into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.Gift_Date),
	'HHS', g.Donor_ID, 0, g.Gift_Date, Mail_AppealCode=t.CRE, g.motive_code, Mail_SegmentCode=s.Segment_Code, '', g.Amount, New_Donor=cast(0 as int),
	1,--RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join HHS..Gifts g on  d.DonorID=g.Donor_ID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.motive_code=mb.AppealCode
where  
	 gift_date between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	--and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1
	and mb.MissionCode = 'HHS'

-- HHS. address matches
INSERT into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.Gift_Date),
	'HHS', g.Donor_ID, 0, g.Gift_Date, Mail_AppealCode=t.CRE, g.motive_code, Mail_SegmentCode=s.Segment_Code, '', g.Amount, New_Donor=cast(0 as int),
	1,--RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.HouseholdHash=d.NCOA_HouseholdHash
left join HHS..Gifts g on  d.DonorID=g.Donor_ID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.motive_code=mb.AppealCode
where  
	 gift_date between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	--and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1
	and mb.MissionCode = 'HHS'

-- ROH uses appealdesc
INSERT into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealDesc, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.AppealDesc=mb.AppealCode
where  g.MissionCode = 'ROH'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1

-- ROH NULLS
INSERT into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealDesc, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
--inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.AppealDesc=mb.AppealCode
where  g.MissionCode = 'ROH'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1
	and g.AppealDesc IS NULL

--- MMM Has extended window
INSERT into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.AppealCode=mb.AppealCode
where  g.MissionCode = 'MMM'
	AND GiftDate between '2023-09-15' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1

-- HRM some use segment code
insert into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.SegmentCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on g.SegmentCode=mb.AppealCode
where  g.MissionCode ='HRM'
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1


-- ALL others
insert into #Responders_MB
select distinct ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.donor_id=d.DonorID
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join DBI_2023_FallMailing..MatchBackAppealCodes mb on  g.AppealCode=mb.AppealCode
where  g.MissionCode in ('BSM', 'CTM', 'GCRM', 'PRM', 'HRM')
	AND GiftDate between '2023-10-01' and '2023-12-31'
	AND g.Amount < 1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
	--and s.Segment_Code<>'SD'
	and ch.seed<>1



Delete #Responders_MB where RespRank>1
--select * from #responders_mb
/*
drop table if exists #Responders_MB
select ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, d.Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, d.StreetAddr, d.City, d.StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
into #Responders_MB
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.HouseholdHash=d.HouseholdHash
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join MatchbackCodes mb on ch.CampaignID=mb.CampaignID and g.AppealCode=mb.Appeal_Code
where g.Amount>0 and ch.seed<>1 and s.Segment_Code<>'SD'
	and g.GiftDate between t.InHomeDate and t.InHomeDate+t.ResponseDays
	-- add in Jon's Matchback Appeal_Code choices for each campaign
	and g.Amount<1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)

--select * from #Responders_MB order by MissionCode, cast(GiftID as int)
*/
--=================================================================
-- add in NCOA address matches to Matchbacks
--=================================================================

insert into #Responders_MB
select ch.CH_ID, c.CampaignID, t.TouchID, Mail_List_Type=s.List_Type, InHomeDate=cast(t.InHomeDate as date), Resp_Days=datediff(dd,t.InHomeDate,g.GiftDate),
	g.MissionCode, g.DonorID, g.GiftID, g.GiftDate, Mail_AppealCode=t.CRE, g.AppealCode, Mail_SegmentCode=s.Segment_Code, g.SegmentCode, g.Amount, New_Donor=cast(0 as int),
	RespRank=ROW_NUMBER() OVER(PARTITION BY g.MissionCode, g.GiftID ORDER BY datediff(dd,t.InHomeDate,g.GiftDate), t.InHomeDate),
	CH_ZIP5=ch.ZIP5, Zip5=d.NCOA_Zip5, CH_FN=ch.FullName, D_FN=FirstName, D_LN=d.LastName, D_SAL=d.Salutation, StreetAddr=d.NCOA_StreetAddr, City=d.NCOA_City, StateCode=d.NCOA_StateCode, CH_HH=CH.HouseholdHash,
	ZIP_County=z.CountyMixedCase
from CampaignHistory ch
left join Touch t on ch.CampaignID=t.CampaignID and ch.TouchID=t.TouchID
left join Campaign c on t.CampaignID=c.CampaignID
left join Donors d on c.MissionCode=d.MissionCode and ch.HouseholdHash=d.NCOA_HouseholdHash
left join Gifts g on d.MissionCode=g.MissionCode and d.DonorID=g.DonorID
left join Segments s on ch.SegmentCode=s.Segment_Code
left join Zips..Zips z on ch.ZIP5=z.ZipCode and PrimaryRecord='P'
-- limit to specific Appeal Codes jon provided
inner join MatchbackCodes mb on ch.CampaignID=mb.CampaignID and g.AppealCode=mb.Appeal_Code
where g.Amount>0 and ch.seed<>1 and s.Segment_Code<>'SD'
	--and g.GiftDate between t.InHomeDate and t.InHomeDate+t.ResponseDays
	-- add in Jon's Matchback Appeal_Code choices for each campaign
	and g.Amount<1000
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders)
	and concat(g.MissionCode, g.DonorID, g.GiftID) not in (select UG=concat(MissionCode, DonorID, GiftID) from #Responders_MB)
	and c.CampaignID in (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)


--=================================================================
-- Delete some #Responders requested by Jon or Bill
--=================================================================

-- delete any 2022 campaign #Responders to House records with GiftDate>12/31/2022
-- DELETE #Responders where left(CampaignID,5)='ACQ22' and Mail_List_Type='House' and year(GiftDate)>2022
-- 22 on 20230220
DELETE #Responders_MB where left(CampaignID,5)='ACQ22' and Mail_List_Type='House' and year(GiftDate)>2022
-- 134 on 20230220

-- delete specific gifts from Responder_Gift_Exclusions table
-- these are individual gifts Bill asked to exclude

--insert into Responder_Gift_Exclusions
--select MissionCode, DonorID, GiftDate, Amount
--from [MatchBack_#Responders_Exclusions_20230321-1]

DELETE #Responders_MB
from #Responders_MB r
inner join Responder_Gift_Exclusions e on r.MissionCode=e.MissionCode and r.DonorID=e.DonorID and r.GiftDate=e.GiftDate and r.Amount=e.Amount

--select * into Responder_Gift_Exclusions_20230324 from Responder_Gift_Exclusions
-- select * from Responder_Gift_Exclusions
-- select top 2 * from Responder_Gift_Exclusions
-- select top 2 * from [MatchBack_#Responders_Exclusions_20230321-1]

--=================================================================
-- NEED TO DEDUPE AND CHOOSE 1ST TOUCH
-- partition by MissionCode, GiftID
-- sort by InHomeDate, Resp_Days,
--=================================================================

-- Delete #Responders where RespRank>1
Delete #Responders_MB where RespRank>1

--=================================================================
-- flag New Donors = GiftDate=min(GiftDate) for MissionCode/DonorID
--=================================================================

UPDATE #Responders set New_Donor=0
UPDATE #Responders_MB set New_Donor=0

UPDATE r set r.New_Donor=1
from #Responders r
inner join (select MissionCode, DonorID, minGiftDate=min(GiftDate) from Gifts group by MissionCode, DonorID) m
	on r.MissionCode=m.MissionCode and r.DonorID=m.DonorID and r.GiftDate=m.minGiftDate

UPDATE r set r.New_Donor=1
from #Responders_MB r
inner join (select MissionCode, DonorID, minGiftDate=min(GiftDate) from Gifts group by MissionCode, DonorID) m
	on r.MissionCode=m.MissionCode and r.DonorID=m.DonorID and r.GiftDate=m.minGiftDate

--=================================================================
-- Insert into aggregate
--=================================================================
--SELECT TOP 500* FROM  DBIAggregateData..Responders
DELETE FROM DBIAggregateData..Responders WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)

INSERT INTO DBIAggregateData..Responders
SELECT CampaignID, MissionCode, DONORID, GiftID, GiftDate, AppealCode, SegmentCode, Amount, FirstName, LastName, Salutation, StreetAddr, StreetAddr2, City, StateCode, Zip5, ZIP_County, New_Donor
FROM #Responders mb
WHERE NOT EXISTS (SELECT CampaignID, MissionCode, donorId, GiftId FROM DBIAggregateData..Responders r WHERE r.CampaignID = mb.CampaignID and r.MissionCode = mb.MissionCode and r.DonorID = mb.DonorID and r.Giftid = mb.GiftID)


DELETE FROM DBIAggregateData..Responders_MB WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
INSERT INTO DBIAggregateData..Responders_MB
SELECT *
FROM #Responders_MB mb
where NOT EXISTS (SELECT CampaignID, MissionCode, donorId, GiftId FROM DBIAggregateData..Responders r WHERE r.CampaignID = mb.CampaignID and r.MissionCode = mb.MissionCode and r.DonorID = mb.DonorID and r.Giftid = mb.GiftID)
   

--select MissionCode, New_Donor, count(*) from #Responders group by MissionCode, New_Donor order by MissionCode, New_Donor

--=================================================================
-- Rollup #Responders and update CampaignResults
--=================================================================

drop table if exists #newdonors
GO
select CampaignID, MissionCode, AppealCode, Zip5, SegmentCode, NewDonors=count(distinct DonorID)
into #newdonors from #Responders
where New_Donor=1
group by CampaignID, MissionCode, AppealCode, Zip5, SegmentCode

drop table if exists #Responders_Rollup
select r.CampaignID, r.MissionCode, r.AppealCode, r.Zip5, r.SegmentCode, Donors=count(distinct donorID), Gifts=count(*), Amount=sum(Amount), NewDonors=max(coalesce(nd.NewDonors,0)), MaxGift=max(Amount)
into #Responders_Rollup
from #Responders r
left join #newdonors nd on r.CampaignID=nd.CampaignID and r.MissionCode=nd.MissionCode and r.AppealCode=nd.AppealCode and r.Zip5=nd.Zip5 and r.SegmentCode=nd.SegmentCode
group by r.CampaignID, r.MissionCode, r.AppealCode, r.Zip5, r.SegmentCode

--=================================================================
-- add rows to CampaignResults for any gifts matching AppealCode
-- but in a ZIP or SegmentCode not mailed
--=================================================================

--select count(*) from #Responders_Rollup
--select distinct CampaignID, MissionCode, AppealCode, Zip5, SegmentCode from #Responders_Rollup
--delete from CampaignResults where CampaignID in (select CampaignID from Campaign where CampaignDate >= '2023-05-01')

insert into CampaignResults
select r.Zip5, z.State, z.CityMixedCase, z.CountyMixedCase, r.CampaignID, r.MissionCode, t.TouchID, t.Wave, MailDate=cast(t.TouchDate as date), t.TouchDesc, r.AppealCode,
	Segment_Code=r.SegmentCode, Segment_Description=coalesce(s.Segment_Description,''), List_Type=coalesce(s.List_Type,''), MailedVolume=0, Cost=0,
	Donors=0, Gifts=0, Amount=0, NewDonors=0, MaxGift=0,
	AttributionType='Combined' 
from #Responders_Rollup r
left join CampaignResults cr on r.CampaignID=cr.CampaignID and r.MissionCode=cr.MissionCode and r.AppealCode=cr.AppealCode and r.ZIP5=cr.Zip5 and r.SegmentCode=cr.Segment_Code and AttributionType='Direct'
left join Touch t on r.CampaignID=t.CampaignID and r.AppealCode=t.CRE
left join Segments s on r.SegmentCode=s.Segment_Code
left join Zips..Zips z on left(r.ZIP5,5)=z.ZipCode and PrimaryRecord='P'
where cr.Zip5 IS NULL or cr.Segment_Code IS NULL


insert into CampaignResults
select r.Zip5, z.State, z.CityMixedCase, z.CountyMixedCase, r.CampaignID, r.MissionCode, t.TouchID, t.Wave, MailDate=cast(t.TouchDate as date), t.TouchDesc, r.AppealCode,
	Segment_Code=r.SegmentCode, Segment_Description=coalesce(s.Segment_Description,''), List_Type=coalesce(s.List_Type,''), MailedVolume=0, Cost=0,
	r.Donors, r.Gifts, r.Amount, r.NewDonors, r.MaxGift,
	AttributionType='Direct'
from #Responders_Rollup r
left join CampaignResults cr on r.CampaignID=cr.CampaignID and r.MissionCode=cr.MissionCode and r.AppealCode=cr.AppealCode and r.ZIP5=cr.Zip5 and r.SegmentCode=cr.Segment_Code and AttributionType='Direct'
left join Touch t on r.CampaignID=t.CampaignID and r.AppealCode=t.CRE
left join Segments s on r.SegmentCode=s.Segment_Code
left join Zips..Zips z on left(r.ZIP5,5)=z.ZipCode and PrimaryRecord='P'
where cr.Zip5 IS NULL or cr.Segment_Code IS NULL


UPDATE cr set
	cr.Donors=0,
	cr.Gifts=0,
	cr.Amount=0,
	cr.NewDonors=0,
	cr.MaxGift=0
from CampaignResults cr

UPDATE cr set
	cr.Donors=r.Donors,
	cr.Gifts=r.Gifts,
	cr.Amount=r.Amount,
	cr.NewDonors=r.NewDonors,
	cr.MaxGift=r.MaxGift
from CampaignResults cr
inner join #Responders_Rollup r on cr.CampaignID=r.CampaignID and cr.MissionCode=r.MissionCode and cr.AppealCode=r.AppealCode and cr.ZIP5=r.Zip5 and cr.Segment_Code=r.SegmentCode
where cr.AttributionType='Direct'



/*
select * from BRM..gifts where gift_id=7372              
select * from #Responders where giftdate='2022-12-12' and Zip5=''
select * from BRM..donors where donor_id=25505
*/

--=================================================================
-- Rollup Matchback #Responders
--=================================================================

drop table if exists #newdonors
GO
select CampaignID, MissionCode, AppealCode=Mail_AppealCode, Zip5, SegmentCode=Mail_SegmentCode, NewDonors=count(distinct DonorID)
into #newdonors from #Responders_MB
where New_Donor=1
group by CampaignID, MissionCode, Mail_AppealCode, Zip5, Mail_SegmentCode

drop table if exists #Responders_MB_Rollup
select r.CampaignID, r.MissionCode, AppealCode=r.Mail_AppealCode, r.Zip5, SegmentCode=r.Mail_SegmentCode, Donors=count(distinct donorID), Gifts=count(*), Amount=sum(Amount), NewDonors=max(coalesce(nd.NewDonors,0)), MaxGift=max(Amount)
into #Responders_MB_Rollup
from #Responders_MB r
left join #newdonors nd on r.CampaignID=nd.CampaignID and r.MissionCode=nd.MissionCode and r.Mail_AppealCode=nd.AppealCode and r.Zip5=nd.Zip5 and r.Mail_SegmentCode=nd.SegmentCode
group by r.CampaignID, r.MissionCode, r.Mail_AppealCode, r.Zip5, r.Mail_SegmentCode

UPDATE cr set
	cr.Donors=r.Donors,
	cr.Gifts=r.Gifts,
	cr.Amount=r.Amount,
	cr.NewDonors=r.NewDonors,
	cr.MaxGift=r.MaxGift
from CampaignResults cr
inner join #Responders_MB_Rollup r on cr.CampaignID=r.CampaignID and cr.MissionCode=r.MissionCode and cr.AppealCode=r.AppealCode and cr.ZIP5=r.Zip5 and cr.Segment_Code=r.SegmentCode
where cr.AttributionType='Matchback'

--=================================================================
-- Combine Direct and Matchback results
--=================================================================

UPDATE cr set
	cr.Donors=coalesce(direct.Donors,0)+coalesce(mb.donors,0),
	cr.Gifts=coalesce(direct.Gifts,0)+coalesce(mb.Gifts,0),
	cr.Amount=coalesce(direct.Amount,0)+coalesce(mb.Amount,0),
	cr.NewDonors=coalesce(direct.NewDonors,0)+coalesce(mb.NewDonors,0),
	cr.MaxGift=case when isnull(direct.MaxGift, 0) >= isnull(mb.MaxGift,0) then direct.MaxGift else mb.MaxGift end
from CampaignResults cr
left join CampaignResults direct on cr.CampaignID=direct.CampaignID and cr.MissionCode=direct.MissionCode and cr.AppealCode=direct.AppealCode and cr.ZIP5=direct.Zip5 and cr.Segment_Code=direct.Segment_Code
	and direct.AttributionType='Direct'
left join CampaignResults mb on cr.CampaignID=mb.CampaignID and cr.MissionCode=mb.MissionCode and cr.AppealCode=mb.AppealCode and cr.ZIP5=mb.Zip5 and cr.Segment_Code=mb.Segment_Code
	and mb.AttributionType='Matchback'
where cr.AttributionType='Combined'

--Clean up 
/*
UPDATE CampaignResults
SET List_Type = 'House',
	Segment_Description = 'Active Donors - Outside Territory'
WHERE Segment_Code = 'ACA'
AND CampaignID IN (SELECT CampaignID FROM Campaign WHERE CampaignDate >= '2023-05-01')
*/

--Mailed volume
;with volume as (
		SELECT Campaignid, appealcode, zip5, touchid, segmentcode, count(*) 'volume'
		FROM CampaignHistory
		WHERE CAMPAIGNID IN (SELECT CampaignID FROM CAMPAIGN WHERE CampaignDate >= '2023-05-01')
		GROUP BY Campaignid, appealcode, zip5, touchid,segmentcode
		
		)
UPDATE cr
SET cr.MailedVolume = v.volume
FROM CampaignResults cr INNER JOIN volume v
  on cr.CampaignID = v.CampaignID and
     cr.AppealCode = v.AppealCode and
	 cr.ZIP5 = v.ZIP5 and
	 cr.TouchID = v.TouchID and
	 cr.Segment_Code = v.SegmentCode
WHERE cr.CAMPAIGNID IN (SELECT CampaignID FROM CAMPAIGN WHERE CampaignDate >= '2023-05-01')

--Costs
UPDATE CampaignResults
set Cost = MailedVolume * touchcost
FROM CampaignResults cr inner join CampaignCosts cc
  on cr.CampaignID = cc.CampaignID and
     cr.TouchID = cc.TouchID and
	 cr.Wave = cc.Wave and 
	 cr.List_Type = cc.Version
WHERE cr.CAMPAIGNID IN (SELECT CampaignID FROM CAMPAIGN WHERE CampaignDate >= '2023-05-01')


--=================================================================
-- Update campaign table
--=================================================================
;WITH Stats as (
		SELECT CampaignID, COUNT(distinct(donorid)) 'Responders', COUNT(*) 'Gifts', SUM(Amount) 'Amount', SUM(New_Donor) 'NewDonors', MAX(amount) 'MaxGift'
		FROM Responders
		WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
		GROUP BY CampaignID
		)
	UPDATE c
	SET c.Responders = s.Responders,
		c.Gifts = s.Gifts,
		c.Amount = s.Amount,
		c.New_Donors = s.NewDonors,
		c.MaxGift = s.MaxGift
	FROM Campaign c INNER JOIN Stats s
	  on c.CampaignID = s.CampaignID

;WITH  MBStats as (
		SELECT CampaignID, COUNT(distinct(donorid)) 'Responders', COUNT(*) 'Gifts', SUM(Amount) 'Amount', SUM(New_Donor) 'NewDonors', MAX(amount) 'MaxGift'
		FROM Responders_MB
		WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
		GROUP BY CampaignID
		)
	UPDATE c
	SET c.MB_Responders = s.Responders,
		c.MB_Gifts = s.Gifts,
		c.MB_Amount = s.Amount,
		c.MB_New_Donors = s.NewDonors,
		c.MB_MaxGift = s.MaxGift
	FROM Campaign c INNER JOIN MBStats s
	  on c.CampaignID = s.CampaignID

UPDATE Campaign
SET ALL_MaxGift = CASE WHEN MaxGift > MB_MaxGift THEN MaxGift ELSE MB_MaxGift END
WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)


-- touch
;WITH Stats as (
		SELECT CampaignID, TouchID, COUNT(distinct(donorid)) 'Responders', COUNT(*) 'Gifts', SUM(Amount) 'Amount', SUM(New_Donor) 'NewDonors', MAX(amount) 'MaxGift'
		FROM #Responders
		WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
		GROUP BY CampaignID, TouchID
		)
	UPDATE c
	SET c.Responders = s.Responders,
		c.Gifts = s.Gifts,
		c.Amount = CAST(s.Amount AS decimal(12,2)),
		c.New_Donors = s.NewDonors,
		c.MaxGift = s.MaxGift
	FROM Touch c INNER JOIN Stats s
	  on c.CampaignID = s.CampaignID and
	     c.TouchID = s.TouchID

;WITH  MBStats as (
		SELECT CampaignID, TouchID, COUNT(distinct(donorid)) 'Responders', COUNT(*) 'Gifts', SUM(Amount) 'Amount', SUM(New_Donor) 'NewDonors', MAX(amount) 'MaxGift'
		FROM #Responders_MB
		WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
		GROUP BY CampaignID,TouchID
		)
	UPDATE c
	SET c.MB_Responders = s.Responders,
		c.MB_Gifts = s.Gifts,
		c.MB_Amount = s.Amount,
		c.MB_New_Donors = s.NewDonors,
		c.MB_MaxGift = s.MaxGift
	FROM Touch c INNER JOIN MBStats s
	  on c.CampaignID = s.CampaignID


UPDATE Touch
SET ALL_MaxGift = CASE WHEN MaxGift > MB_MaxGift THEN MaxGift ELSE MB_MaxGift END
WHERE CampaignID IN (SELECT CampaignID FROM DBI_2023_FallMailing..Campaign)
--=================================================================
-- basic report
--=================================================================

select MissionCode, CampaignID, AttributionType, MailedVolume=sum(MailedVolume), Donors=sum(Donors), Gifts=sum(Gifts), Amount=sum(Amount), NewDonors=sum(NewDonors)
from CampaignResults
where MissionCode not in ('FRM  ','RRM  ')
and AttributionType='Direct'
group by MissionCode, CampaignID, AttributionType
order by MissionCode, CampaignID, AttributionType

select MissionCode, CampaignID, AttributionType, MailedVolume=sum(MailedVolume), Donors=sum(Donors), Gifts=sum(Gifts), Amount=sum(Amount), NewDonors=sum(NewDonors)
from CampaignResults
where MissionCode not in ('FRM  ','RRM  ')
and AttributionType='Matchback'
group by MissionCode, CampaignID, AttributionType
order by MissionCode, CampaignID, AttributionType

select MissionCode, CampaignID, AttributionType, MailedVolume=sum(MailedVolume), Donors=sum(Donors), Gifts=sum(Gifts), Amount=sum(Amount), NewDonors=sum(NewDonors)
from CampaignResults
where MissionCode not in ('FRM  ','RRM  ')
and AttributionType='Combined'
group by MissionCode, CampaignID, AttributionType
order by MissionCode, CampaignID, AttributionType

/*

select * from CampaignResults where MissionCode='BSM  ' order by Segment_Code
select Segment_Code, MissionCode, count(*) from CampaignResults group by Segment_Code, MissionCode order by Segment_Code, MissionCode

select count(*) from CampaignHistory where CampaignID not like '%FRM%' and CampaignID not like '%RRM%'

select donors=count(distinct AppealCode+MissionCode+DonorID+SegmentCode), gifts=count(*), Amount=sum(Amount) from #Responders
select donors=sum(Donors), gifts=sum(gifts), amount=sum(Amount), new_donors=sum(NewDonors) from #Responders_Rollup

select donors=count(distinct Mail_AppealCode+MissionCode+DonorID+Mail_SegmentCode), gifts=count(*), Amount=sum(Amount) from #Responders_MB
select donors=sum(Donors), gifts=sum(gifts), amount=sum(Amount), new_donors=sum(NewDonors) from #Responders_MB_Rollup

select AttributionType, donors=sum(Donors), gifts=sum(gifts), amount=sum(Amount), new_donors=sum(NewDonors) from CampaignResults group by AttributionType order by AttributionType

select * from CampaignResults where MailedVolume=0
select * from CampaignResults where ZIP5='44321' and CampaignID='ACQ22ROH' and TouchID='W4' and AppealCode='22D122' and Segment_Code='91'

-- select count(*), Gifts=sum(Gifts), Amount=sum(Amount), New_Donors=sum(New_Donor) from CampaignHistory where Responder=1

*/


Select *
  FROM Responders
Where CampaignID LIKE '%23'
And MissionCode = 'BRM'