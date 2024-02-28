USE DBIAggregateData
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--select top 5 * from DBI_2022_FallMailing..BRM_Wave1_Output

DROP TABLE IF EXISTS [CampaignHistory]

CREATE TABLE [dbo].[CampaignHistory](
	CH_ID int identity (1,1),
	[DBID] [varchar](100) NULL,
	[donor_id] [varchar](50) NULL,
	[CampaignID] [varchar](25) NOT NULL,
	[Seed] [smallint] DEFAULT 0,
	[SegmentCode] [varchar](50) NULL,
	[TouchID] [varchar](25) NOT NULL,
	[Version] [varchar](25) NULL,
	[Segment] [varchar](25) NULL,
	[AppealCode] [varchar](25) NULL,
--	[ChannelTable] [varchar](50) NULL,
--	[MissionCode] [varchar](4) NOT NULL,
--	[HouseholdID] [varchar](100) NULL,
	Organization_Name [varchar](100) NULL,
	FullName [varchar](100) NULL,
--	Address1 [varchar](100) NULL,
--	Address2 [varchar](100) NULL,
	City [varchar](100) NULL,
	[State] [varchar](2) NULL,
	[ZIP5] [varchar](5) NULL,
	HouseholdHash [varchar](500) NULL,
	[Responder] int DEFAULT 0,
	[Gifts] int DEFAULT 0,
	Amount decimal(12,2) DEFAULT 0.00,
	New_Donor int DEFAULT 0,
	MB_Responder int DEFAULT 0,
	MB_Gifts int DEFAULT 0,
	MB_Amount decimal(12,2) DEFAULT 0.00,
	MB_New_Donor int DEFAULT 0
-- CONSTRAINT [PK_PromoHistory] PRIMARY KEY CLUSTERED 
--(
--	[DBID] ASC,
--	[CampaignID] ASC,
----	[Effort_No] ASC,
--	[SegmentCode] ASC,
--	[TouchID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


