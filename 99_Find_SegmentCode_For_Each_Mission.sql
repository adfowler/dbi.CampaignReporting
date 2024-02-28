

use DBIAggregateData
GO

-- [X] CTM
select top 5 * from CTM..gifts where left(appeal_code,4)='FQ22' and segment_code IS NOT NULL
select segment_code, count(*) from CTM..gifts group by segment_code order by 1

-- [X] GCRM
select top 5 * from GCRM..gifts
select appeal_code, count(*) from GCRM..gifts group by appeal_code order by 1

select appeal_code, SegmentCode=case when left(appeal_code,4)='FQ22' then substring(appeal_code,7,100) else NULL end
from GCRM..gifts
order by case when left(appeal_code,4)='FQ22' then substring(appeal_code,7,100) else NULL end desc

-- [X] MMM
select top 5 * from MMM..gifts
select appeal_code, count(*) from MMM..gifts group by appeal_code order by 1

select appeal_code, SegmentCode=case when left(appeal_code,4)='Q221' then substring(appeal_code,7,100) else NULL end
from MMM..gifts
order by case when left(appeal_code,4)='Q221' then substring(appeal_code,7,100) else NULL end desc

-- [X] ROH
select top 5 * from ROH..gifts
select appeal_desc, CHARINDEX(' ', appeal_desc), count(*) from ROH..gifts where appeal_desc like '%22D1%' group by appeal_desc order by 1

select appeal_desc, SegmentCode=case when left(appeal_desc,4)='22D1' then substring(appeal_desc,7,CHARINDEX(' ', appeal_desc)-7) else NULL end
from ROH..gifts
order by case when left(appeal_desc,4)='22D1' then substring(appeal_desc,7,CHARINDEX(' ', appeal_desc)-7) else NULL end desc

-- [X] HHS
select top 5 * from HHS..gifts
select motive_code, count(*) from HHS..gifts group by motive_code order by 1
select motive_code, SegmentCode=appeal_code, count(*) from HHS..gifts where left(motive_code,4)='FQ22' group by motive_code, appeal_code order by motive_code, appeal_code
-- SegmentCode=case when left(motive_code,4)='FQ22' then appeal_code else NULL end

-- [X] CRM
select top 5 * from CRM..gifts
select segment_code, count(*) from CRM..gifts group by segment_code order by 1

select segment_code, SegmentCode=case when left(segment_code,3)='Q22' then substring(segment_code,6,100) else NULL end from CRM..gifts
order by case when left(segment_code,3)='Q22' then substring(segment_code,6,100) else NULL end desc

-- [X] PRM
select top 5 * from PRM..gifts
select appeal_code, count(*) from PRM..gifts group by appeal_code order by 1

select appeal_code, SegmentCode=case when left(appeal_code,3)='Q22' then substring(appeal_code,6,100) else NULL end from PRM..gifts
order by case when left(appeal_code,3)='Q22' then substring(appeal_code,6,100) else NULL end desc

-- [_] BSM
select top 5 * from BSM..gifts

-- [X] BRM
select top 5 * from BRM..gifts
select campaign_code, count(*) from BRM..gifts group by campaign_code order by 1

select campaign_code, SegmentCode=case when left(campaign_code,3)='Q22' then substring(campaign_code,6,100) else NULL end from BRM..gifts
order by case when left(campaign_code,3)='Q22' then substring(campaign_code,6,100) else NULL end desc

select MissionCode, SegmentCode, count(*) from Gifts where SegmentCode IS NOT NULL group by MissionCode, SegmentCode order by MissionCode, SegmentCode

