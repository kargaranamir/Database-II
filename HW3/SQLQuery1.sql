CREATE TABLE [dbo].[Trn_Over](
	[Dep_Id] [varchar](21) NULL,
	[TrnDate] [date] NULL,
	[TrnTime] [varchar](6) NULL,
	[Trn_over] [int] NULL,
) ON [PRIMARY]


CREATE TABLE [dbo].[Factdeptrn](
	[Dep_Id] [varchar](21) NULL,
	[TrnDate] [date] NULL,
	[TrnTime] [varchar](6) NULL,
	[Trn_over] [int] NULL,
	[Balance] [int] NULL,
) ON [PRIMARY]




GO
SET ANSI_PADDING OFF
GO
--insert question data to Trn_Src_Des table
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'10', CAST(0x233F0B00 AS Date), N'101000', 1000)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'11', CAST(0x233F0B00 AS Date), N'101000', 1000)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'10', CAST(0x233F0B00 AS Date), N'091000', -200)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'11', CAST(0x243F0B00 AS Date), N'080023', -300)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'11', CAST(0x273F0B00 AS Date), N'151201', 700)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'10', CAST(0x273F0B00 AS Date), N'151201', 700)
INSERT [dbo].[Trn_Over] ([Dep_Id], [TrnDate], [TrnTime], [Trn_over]) VALUES (N'11', CAST(0x503F0B00 AS Date), N'132022', 1700)


CREATE TABLE [dbo].[FactAcc](
	[Dep_Id] [varchar](21) NULL,
	[Balance] [int] NULL,
) ON [PRIMARY]


CREATE TABLE [dbo].[Temp1](
	[Dep_Id] [varchar](21) NULL,
	[TrnDate] [date] NULL,
	[TrnTime] [varchar](6) NULL,
	[Trn_over] [int] NULL,
) ON [PRIMARY]

CREATE TABLE [dbo].[Temp2](
	[Dep_Id] [varchar](21) NULL,
	[TrnTime] [varchar](6) NULL,
	[Trn_over] [int] NULL,
	[ran] [int] NULL,
) ON [PRIMARY]

CREATE TABLE [dbo].[Temp3](
	[Dep_Id] [varchar](21) NULL,
	[TrnTime] [varchar](6) NULL,
	[Trn_over] [int] NULL,
	[balance] [int] NULL,
	[ran] [int] NULL,
) ON [PRIMARY]

CREATE TABLE [dbo].[TempAcc](
	[Dep_Id] [varchar](21) NULL,
	[Balance] [int] NULL,
) ON [PRIMARY]




CREATE PROCEDURE Exam as
begin

truncate table [dbo].[FactAcc]

declare @currdate date;

	set @currdate = CAST('2019-01-01' as date)
	while @currdate <= CAST('2019-03-01' as date) 
	begin 

	truncate table [dbo].[Temp1]
	truncate table [dbo].[Temp2]
	truncate table [dbo].[Temp3]
	truncate table [dbo].[TempAcc]
  
	insert into [dbo].[Temp1]
	select [Dep_Id], [TrnDate], [TrnTime], [Trn_over]
	from [dbo].[Trn_Over] where [dbo].[Trn_Over].TrnDate = @currdate;


	insert into [dbo].[Temp2]
	select [Dep_Id], [TrnTime], [Trn_over], RANK() OVER (PARTITION BY [Dep_Id] ORDER BY [TrnTime] ASC ) [ran] 
	from [dbo].[Temp1]


	insert into [dbo].[Temp3]
	select t1.[Dep_Id], t1.[TrnTime], t1.[Trn_over] ,sum(t2.[Trn_over]) as [balance] , t1.[ran]
	from [dbo].[Temp2] as t1 inner join [dbo].[Temp2] as t2 on (t1.[Dep_Id]=t2.[Dep_Id])
	where t1.[TrnTime] > = T2.[TrnTime] and t1.[ran] >= t2.[ran]

	group by t1.[TrnTime], t1.[Dep_Id], t1.Trn_over , t1.[ran]

	insert into [dbo].[Factdeptrn]
	select t1.[Dep_Id], @currdate as [TrnDate] , t1.[TrnTime], t1.[Trn_over] , (t1.[balance] + isnull (t2.[Balance],0)) [balance]
	from [dbo].[Temp3] as t1 left join [dbo].[FactAcc] as t2 on (t1.[Dep_Id]=t2.[Dep_Id])


	insert into [dbo].[TempAcc]
	select isnull(t1.[Dep_Id],t2.[Dep_Id]) , (sum(isnull(t1.[Trn_over],0)) + isnull(t2.[Balance],0)) [balance]
	from [dbo].[Temp1] as t1 full outer join [dbo].[FactAcc] as t2 on (t1.[Dep_Id]=t2.[Dep_Id])
	group by isnull(t1.[Dep_Id],t2.[Dep_Id]) , t2.[Balance]
		
	truncate table [dbo].[FactAcc]

	insert into [dbo].[FactAcc]
	select *
	from [dbo].[TempAcc]


	set @currdate = DATEADD(day, +1, @currdate)
	end

end 


Exec Exam

select * From [dbo].[Factdeptrn]
select * From [dbo].[FactAcc]
select * From  [dbo].[TempAcc]
select * From [dbo].[Trn_Over]


delete  From [dbo].[Factdeptrn]
delete  From [dbo].[FactAcc]
delete  From  [dbo].[TempAcc]



