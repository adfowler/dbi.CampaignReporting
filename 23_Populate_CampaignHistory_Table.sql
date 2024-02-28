
USE DBI_2023_FallMailing
GO

-- Delete CampaignHistory

--=======================================================
-- gather HouseholHash keys
--=======================================================
/*
drop table if exists #tmp
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
INTO #Tmp
FROM DBI_2023_FallMailing..FinalAvailableSelection
UNION
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
FROM DBI_2023_FallMailing..FinalAvailableSelection_Bkp_20220706
UNION
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
FROM DBI_2023_FallMailing..FinalAvailableSelection_Multis
UNION
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
FROM DBI_2023_FallMailing..FinalAvailableSelection_RRM
UNION
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
FROM DBI_2023_FallMailing..FinalAvailableSelection_Vista
UNION
SELECT FinalAddress1, FinalAddress2, FinalCity, FinalZipCode, HouseholdHash
FROM DBI_2023_FallMailing..FinalAvailableSelection_Vista2

CREATE INDEX tmp ON #Tmp(FinalAddress1, FinalAddress2, FinalCity, FinalZipCode)
*/
-- select len(HouseholdHash), count(*) from #tmp group by len(HouseholdHash)

--=======================================================
-- BRM 2022 Fall
--=======================================================
DELETE CampaignHistory WHERE CampaignID LIKE 'BRM%23'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='BRMW2D123', Seed=0, SegmentCode, TouchID='Drop 1', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5),  HouseholdHash, Responder=0, Gifts=0, Amount=0
from BRM_Wave2_Drop1_Q2309_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='BRMW5D223', Seed=0, SegmentCode, TouchID='Drop 2A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..BRM_Wave5_Drop2_Q23111_Output  a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='BRMW5D223', Seed=0, SegmentCode, TouchID='Drop 2B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash HouseholdHash, Responder=0, Gifts=0, Amount=0
from BRM_Wave5_Drop2_Q23112_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode


--=======================================================
-- BSM 2022 Fall
--=======================================================
delete CampaignHistory where CampaignID = 'BSMW2D123'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='BSMW2D123', Seed=0, SegmentCode, TouchID='Drop 1', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5),  HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..BSM_Wave2_Drop1_Q2310_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode
--left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode

--=======================================================
-- CRM 2023 Fall
--=======================================================

/*
NO CRM IN 2023

insert into CampaignHistory
select DBID, Donor_ID, CampaignID='ACQ23CRM', Seed=0, SegmentCode, TouchID='W1', [Version], Segment, AppealCode,
	Organization_Name, FullName, City=a.FinalCity, State=FinalState, ZIP5=left(Zip,5), b.HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CRM_Wave1_Output a
left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode

insert into CampaignHistory
select DBID, Donor_ID, CampaignID='ACQ23CRM', Seed=0, SegmentCode, TouchID='W4', [Version], Segment, AppealCode,
	Organization_Name, FullName, City=a.FinalCity, State=FinalState, ZIP5=left(Zip,5), b.HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CRM_Wave4_Output a
left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode
*/
--=======================================================
-- CTM 2022 Fall
--=======================================================
delete CampaignHistory where CampaignID like 'CTM%23'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW2D123', Seed=0, SegmentCode, TouchID='Drop 1A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave2_Drop1_FQ23101_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW2D123', Seed=0, SegmentCode, TouchID='Drop 1B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave2_Drop1_FQ23102_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW2D123', Seed=0, SegmentCode, TouchID='Drop 1C', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave2_Drop1_FQ23103_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW4D223', Seed=0, SegmentCode, TouchID='Drop 2', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave4_Drop2_FQ23300_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW5D323', Seed=0, SegmentCode, TouchID='Drop 3A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave5_Drop3_FQ23401_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='CTMW5D323', Seed=0, SegmentCode, TouchID='Drop 3B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, a.City, a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..CTM_Wave5_Drop3_FQ23402_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- FRM 2022 Fall
--=======================================================
/*

NO FRM
insert into CampaignHistory
select DBID, Donor_ID, CampaignID='ACQ23FRM', Seed=0, SegmentCode, TouchID='W1', [Version], Segment, AppealCode,
	Organization_Name, FullName, City=a.FinalCity, State=FinalState, ZIP5=left(Zip,5), b.HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..FRM_Wave1_Output a
left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode
*/
--=======================================================
-- GCRM 2022 Fall
--=======================================================
delete CampaignHistory where campaignid like 'GCRM%23'

insert into CampaignHistory  (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='GCRMW2D123', Seed=0, SegmentCode, TouchID='Drop 1', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..GCRM_Wave2_Drop1_FQ2310_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode


insert into CampaignHistory  (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='GCRMW4D223', Seed=0, SegmentCode, TouchID='Drop 2', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..GCRM_Wave4_Drop2_FQ2320_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode


--=======================================================
-- HHS 2022 Fall
--=======================================================
delete CampaignHistory where CampaignID like 'HHS%23'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='HHSW2D123', Seed=0, SegmentCode, TouchID='Drop 1A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..HHS_Wave2_Drop1_FQ23101_Output a  left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='HHSW2D123', Seed=0, SegmentCode, TouchID='Drop 1B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..HHS_Wave2_Drop1_FQ23202_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode


insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='HHSW5D223', Seed=0, SegmentCode, TouchID='Drop 2', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..HHS_Wave5_Drop2_FQ23300_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- HRM 2023 Fall
--=======================================================
DELETE CampaignHistory WHERE CampaignID = 'HRMW4D123'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='HRMW4D123', Seed=0, SegmentCode, TouchID='Drop 1', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..HRM_Wave4_Drop1_Q2311_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode


--=======================================================
-- MMM 2022 Fall
--=======================================================
DELETE CampaignHistory WHERE CampaignID in('MMMWD1223', 'MMMW4D323')

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMMWD1223', Seed=0, SegmentCode, TouchID='Drop 1A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..MMM_Wave1_Drop1_Q23100_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMMWD1223', Seed=0, SegmentCode, TouchID='Drop 2B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..MMM_Wave2_Drop2_Q23101_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMMWD1223', Seed=0, SegmentCode, TouchID='Drop 2C', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5),HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..MMM_Wave2_Drop2_Q23102_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMMWD1223', Seed=0, SegmentCode, TouchID='Drop 2D', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..MMM_Wave2_Drop2_Q23103_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMMW4D323', Seed=0, SegmentCode, TouchID='Drop 3', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..MMM_Wave4_Drop3_Q23110_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- NA 2023 Fall
--=======================================================
DELETE CampaignHistory WHERE CampaignID = 'NAWD24123'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='NAWD24123', Seed=0, SegmentCode, TouchID='Drop 2', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..NA_Wave4_Drop2_Q2311_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- PRM 2023 Fall
--=======================================================
DELETE FROM CampaignHistory WHERE CampaignID IN ('PRMW3D123', 'PRMW5D223')

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='PRMW3D123', Seed=0, SegmentCode, TouchID='Drop 1', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..PRM_Wave3_Drop1_Q23100_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='PRMW5D223', Seed=0, SegmentCode, TouchID='Drop 2A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..PRM_Wave5_Drop2_Q23121_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='PRMW5D223', Seed=0, SegmentCode, TouchID='Drop 2B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..PRM_Wave5_Drop2_Q23122_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- ROH 2023 Fall
--=======================================================
DELETE FROM CampaignHistory WHERE CampaignID IN ('ROHW2D123', 'ROHW5D223')

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='ROHW2D123', Seed=0, SegmentCode, TouchID='Drop 1A', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..ROH_Wave2_Drop1_23D101_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='ROHW2D123', Seed=0, SegmentCode, TouchID='Drop 1B', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..ROH_Wave2_Drop1_23D102_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='ROHW2D123', Seed=0, SegmentCode, TouchID='Drop 1C', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..ROH_Wave2_Drop1_23D103_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='ROHW5D223', Seed=0, SegmentCode, TouchID='Drop 2', [Version], Segment, AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..ROH_Wave5_Drop2_23D121_Output a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode

--=======================================================
-- RRM 2022 Fall
--=======================================================
/*
insert into CampaignHistory
select DBID, Donor_ID, CampaignID='ACQ23RRM', Seed=0, SegmentCode, TouchID='W1', [Version], Segment, AppealCode,
	Organization_Name, FullName, City=a.FinalCity, State=FinalState, ZIP5=left(Zip,5), b.HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..RRM_Wave1_Output a
left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode

insert into CampaignHistory
select DBID, Donor_ID, CampaignID='ACQ23RRM', Seed=0, SegmentCode, TouchID='W4', [Version], Segment, AppealCode,
	Organization_Name, FullName, City=a.FinalCity, State=FinalState, ZIP5=left(Zip,5), b.HouseholdHash, Responder=0, Gifts=0, Amount=0
from DBI_2023_FallMailing..RRM_Wave4_Output a
left join #Tmp b ON a.FinalAddress1 = b.FinalAddress1 AND a.FinalAddress2 = b.FinalAddress2 AND a.FinalCity = b.FinalCity AND left(Zip,5) = b.FinalZipCode
*/



--=======================================================
-- WAM Extra from JVO
--=======================================================
delete campaignhistory where CampaignID = 'MMM24WAM'

insert into CampaignHistory (DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
select DBID, a.Donor_ID, CampaignID='MMM24WAM', Seed=0, SegmentCode, TouchID='Drop1', [Version], '', AppealCode,
	a.Organization_Name, a.FullName, City=a.City, State=a.State, ZIP5=left(Zip,5), HouseholdHash, Responder=0, Gifts=0, Amount=0
from  [MMM_WalkAMile_20231211].[dbo].[MMM_24WAM_Output_Final] a left join NameCruncherResults_v2 b
  ON a.Address1 = b.Address1 AND a.Address2 = b.Address2 AND a.City = b.City AND left(Zip,5) = b.ZipCode



--=======================================================
-- Update HouseholdHash - mailfiles had 2 concat together
--=======================================================

UPDATE CampaignHistory set HouseholdHash=substring(HouseholdHash,3,64)

--=======================================================
-- update seed flag
--=======================================================
UPDATE CampaignHistory set Seed=1
	where HouseholdHash IS NULL
	--where DBID like '%SEED%'
	--or (FullName='Bill Miller' and Address='PO Box 144' and Zip5=56362)
	--or (FullName='Jo Ann Carpenter' and Address='715 Second Street NE' and Zip5=44704)

--=======================================================
-- Insert into CampaignHistory
--=======================================================
DELETE DBIAggregateData..CampaignHistory WHERE CampaignID IN (SELECT CampaignID FROM CampaignHistory)


INSERT INTO DBIAggregateData..CampaignHistory(DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount)
SELECT DBID, Donor_ID, CampaignID, Seed, SegmentCode, TouchID, Version, Segment, AppealCode,
	Organization_Name, FullName, City, State, ZIP5, HouseholdHash, Responder, Gifts, Amount
FROM CampaignHistory

--=======================================================
-- counts
--=======================================================

select a.CampaignID, b.TouchID, Mailed=sum(case when c.CampaignID IS NOT NULL then 1 else 0 end)
from Campaign a
left join Touch b on a.CampaignID=b.CampaignID
left join CampaignHistory c on b.CampaignID=c.CampaignID and b.TouchID=c.TouchID
where Seed=0
group by a.CampaignID, b.TouchID order by a.CampaignID, b.TouchID

--=======================================================
-- populate random responses for testing
--=======================================================

-- select top 10 * from CampaignHistory order by NEWID()

/*
-- set 0.5% of people randomly to responders
-- UPDATE CampaignHistory set Responder=0
UPDATE CampaignHistory set Responder=1
where CH_ID in (select top 0.5 percent CH_ID from CampaignHistory where Seed=0 order by NEWID())

-- set gifts randomly to 1 or 2
--UPDATE CampaignHistory set Gifts=0
UPDATE CampaignHistory set Gifts=case when CH_ID % 2 = 0 then 2 else 1 end
where Responder=1

-- set responders randomly to give between $20-$200
-- UPDATE CampaignHistory set Amount=0
UPDATE CampaignHistory set Amount=20+(right(CH_ID,1)*20)
where Responder=1
*/

-- select * from CampaignHistory where Responder=1

-- select count(*) from CampaignHistory

/*
select top 2 * from Campaign
select top 2 * from Touch
select top 2 * from CampaignHistory order by NEWID()
--select top 2 * from DBI_2023_FallMailing..PromoHistory order by NEWID()
select top 5 * from DBI_2023_FallMailing..BRM_Wave1_Output order by NEWID()
-- select * from DBI_2023_FallMailing..BRM_Wave1_Output order by NEWID()
*/





