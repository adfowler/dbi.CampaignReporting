USE DBIAggregateData
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [Touch]
CREATE TABLE [dbo].[Touch](
	[CampaignID] [varchar](10) NOT NULL,
	[TouchID] [varchar](10) NOT NULL,
	[TouchDate] [smalldatetime] NULL,
	[InHomeDate] [smalldatetime] NULL,
	[TouchDesc] [varchar](255) NULL,
	[TouchCount] [int] NULL,
	[TouchStatus] [char](1) NULL,
	[PkgID] [varchar](10) NULL,
	[Letter] [varchar](10) NULL,
	[CRE] [varchar](10) NULL,
	[Wave] [char](1) NULL,
	[ResponseDays] INT Default 60,
	[TouchCost] decimal(12,2) Default 0.60,
	[Solicits] int NOT NULL DEFAULT 0,
	[Responders] int NOT NULL DEFAULT 0,
	[Gifts] int NOT NULL DEFAULT 0,
	[Amount] decimal(12,2) NOT NULL DEFAULT 0,
	New_Donors int DEFAULT 0,
	MB_Responders int NOT NULL DEFAULT 0,
	MB_Gifts int NOT NULL DEFAULT 0,
	MB_Amount decimal(12,2) NOT NULL DEFAULT 0,
	MB_New_Donors int DEFAULT 0,
 CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED 
(
	[CampaignID] ASC,
	[TouchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER Table Touch add New_Donors int DEFAULT 0
ALTER Table Touch_ZIP add New_Donors int DEFAULT 0
ALTER Table Campaign add New_Donors int DEFAULT 0
ALTER Table CampaignHistory add New_Donor int DEFAULT 0
