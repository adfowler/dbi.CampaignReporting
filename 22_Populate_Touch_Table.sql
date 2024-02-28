
USE DBIAggregateData
GO

insert into [Touch] (CampaignID, TouchID, TouchDate, TouchDesc, TouchCount, TouchStatus, PkgID, Letter, CRE, Wave, ResponseDays, TouchCost)
select *, ResponseDays=60, TouchCost=0.60
from DBI_2022_FallMailing..Channel

insert into [Touch] (CampaignID, TouchID, TouchDate, TouchDesc, TouchCount, TouchStatus, PkgID, Letter, CRE, Wave)
select 'ACQ22CTM','W4','2022-07-15 09:20:00','(Touch Universe)',0,'C','CTM-S','SW-S','FQ22400','4'

insert into [Touch] (CampaignID, TouchID, TouchDate, TouchDesc, TouchCount, TouchStatus, PkgID, Letter, CRE, Wave)
select 'ACQ22MMM','W3','2022-07-25 10:35:00','(Touch Universe)',0,'C','MMM-S','SW-S','Q22110','3'

insert into [Touch] (CampaignID, TouchID, TouchDate, TouchDesc, TouchCount, TouchStatus, PkgID, Letter, CRE, Wave)
select 'ACQ22ROH','W4','2022-07-21 15:50:00','(Touch Universe)',0,'C','ROH-S','SW-S','22D122','4'

Update Touch set InHomeDate=case
	when substring(CampaignID,6,10) in ('BRM','BSM','CRM','CTM','FRM','GCRM','HHS','MMM','NA','PRM','ROH','RRM')
		AND TouchID='W1' THEN '9/29/2022'
	when substring(CampaignID,6,10) in ('PRM')
		AND TouchID='W2' THEN '10/14/2022'
	when substring(CampaignID,6,10) in ('CTM','GCRM','HHS','MMM','NA','ROH')
		AND TouchID='W3' THEN '11/2/2022'
	when substring(CampaignID,6,10) in ('BRM','CRM','PRM','RRM')
		AND TouchID='W4' THEN '11/30/2022'
	when substring(CampaignID,6,10) in ('CTM','HHS','MMM','ROH')
		AND TouchID='W4' THEN '11/29/2022'
	end

Update t set t.TouchDesc=d.TouchDesc
from Touch t
--left join Campaign c on t.CampaignID=c.CampaignID
left join z_ACQ_2022_Wave_Desc d on t.CampaignID=concat('ACQ22',d.MissionCode) and t.TouchID=d.TouchID

/*
select * from z_ACQ_2022_Wave_Desc

--select top 5 * from DBI_2022_FallMailing..Channel
--select top 5 * from [Touch]

select * from Touch order by CampaignID, TouchID
*/




