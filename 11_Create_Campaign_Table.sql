USE DBIAggregateData
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [Campaign]
CREATE TABLE [dbo].[Campaign](
	[CampaignID] [varchar](10) NOT NULL,
	[CampaignDesc] [varchar](255) NOT NULL,
	[MissionCode] [varchar](5) NOT NULL,
	[CampaignDate] [smalldatetime] NOT NULL,
	[Solicits] int NOT NULL DEFAULT 0,
	Responders int NOT NULL DEFAULT 0,
	Gifts int NOT NULL DEFAULT 0,
	Amount decimal(12,2) NOT NULL DEFAULT 0,
	New_Donors int DEFAULT 0,
	MB_Responders int NOT NULL DEFAULT 0,
	MB_Gifts int NOT NULL DEFAULT 0,
	MB_Amount decimal(12,2) NOT NULL DEFAULT 0,
	MB_New_Donors int DEFAULT 0
 CONSTRAINT [PK_Campaign] PRIMARY KEY CLUSTERED 
(
	[CampaignID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


