
USE DBIAggregateData
GO

--=======================================================
-- Update Solicits, Responders, Gifts, Amount
-- on CampaignHistory and Touch Tables
--=======================================================

UPDATE Campaign set Solicits=0, Responders=0, Gifts=0, Amount=0, New_Donors=0, MB_Responders=0, MB_Gifts=0, MB_Amount=0, MB_New_Donors=0
UPDATE Campaign set Solicits=stats.Solicits,
	Responders=stats.Responders, Gifts=stats.Gifts, Amount=stats.Amount, New_Donors=stats.New_Donors, MaxGift=stats.MaxGift,
	MB_Responders=stats.MB_Responders, MB_Gifts=stats.MB_Gifts, MB_Amount=stats.MB_Amount, MB_New_Donors=stats.MB_New_Donors, MB_MaxGift=stats.MB_MaxGift,
	ALL_MaxGift=stats.ALL_MaxGift
from Campaign
left join (select CampaignID, Solicits=coalesce(count(*),0),
	Responders=coalesce(sum(Responder),0), Gifts=coalesce(sum(Gifts),0), Amount=coalesce(sum(Amount),0), New_Donors=coalesce(sum(New_Donor),0), MaxGift=max(coalesce(MaxGift,0)),
	MB_Responders=coalesce(sum(MB_Responder),0), MB_Gifts=coalesce(sum(MB_Gifts),0), MB_Amount=coalesce(sum(MB_Amount),0), MB_New_Donors=coalesce(sum(MB_New_Donor),0), MB_MaxGift=max(coalesce(MB_MaxGift,0)),
	ALL_MaxGift=max(coalesce(ALL_MaxGift,0))
	from CampaignHistory group by CampaignID) stats on Campaign.CampaignID=stats.CampaignID
where stats.CampaignID IS NOT NULL

UPDATE Touch set Solicits=0, Responders=0, Gifts=0, Amount=0, New_Donors=0, MB_Responders=0, MB_Gifts=0, MB_Amount=0, MB_New_Donors=0
UPDATE Touch set Solicits=stats.Solicits,
	Responders=stats.Responders, Gifts=stats.Gifts, Amount=stats.Amount, New_Donors=stats.New_Donors, MaxGift=stats.MaxGift,
	MB_Responders=stats.MB_Responders, MB_Gifts=stats.MB_Gifts, MB_Amount=stats.MB_Amount, MB_New_Donors=stats.MB_New_Donors, MB_MaxGift=stats.MB_MaxGift,
	ALL_MaxGift=stats.ALL_MaxGift
from Touch
left join (select CampaignID, TouchID, Solicits=coalesce(count(*),0),
	Responders=coalesce(sum(Responder),0), Gifts=coalesce(sum(Gifts),0), Amount=coalesce(sum(Amount),0), New_Donors=coalesce(sum(New_Donor),0), MaxGift=max(coalesce(MaxGift,0)),
	MB_Responders=coalesce(sum(MB_Responder),0), MB_Gifts=coalesce(sum(MB_Gifts),0), MB_Amount=coalesce(sum(MB_Amount),0), MB_New_Donors=coalesce(sum(MB_New_Donor),0), MB_MaxGift=max(coalesce(MB_MaxGift,0)),
	ALL_MaxGift=max(coalesce(ALL_MaxGift,0))
	from CampaignHistory group by CampaignID, TouchID) stats on Touch.CampaignID=stats.CampaignID and Touch.TouchID=stats.TouchID
where stats.CampaignID IS NOT NULL and stats.TouchID IS NOT NULL

--=======================================================
-- Create Touch response table @ the ZIP level
--=======================================================

drop table if exists Touch_ZIP
select CampaignID, TouchID, ZIP5, Solicits=count(*),
	Responders=sum(Responder), Gifts=sum(Gifts), Amount=sum(Amount), New_Donors=coalesce(sum(New_Donor),0),
	MB_Responders=sum(MB_Responder), MB_Gifts=sum(MB_Gifts), MB_Amount=sum(MB_Amount), MB_New_Donors=coalesce(sum(MB_New_Donor),0)
into Touch_Zip
from CampaignHistory ch
group by CampaignID, TouchID, ZIP5

/*
select top 200 * from CampaignHistory where ALL_MaxGift>0 order by NEWID()
select * from Campaign
select * from Touch
select top 1000 * from Touch_Zip order by NEWID()

ALTER Table Campaign alter column Amount decimal(12,2)
ALTER Table Campaign alter column MB_Amount decimal(12,2)
ALTER Table Touch alter column Amount decimal(12,2)
ALTER Table Touch alter column MB_Amount decimal(12,2)
*/





