CREATE TABLE [Deposit_Turnover](
[depositkey] [bigint] NOT NULL,
[turn_time] [datetime] NULL,
[turnover_bed] [numeric](18, 0) NULL,
[turnover_bes] [numeric](18, 0) NULL,
[turn_id] [int] NULL
)

CREATE TABLE [FactDeposit](
[depositkey] [bigint] NOT NULL,
[Effdate] [date] NULL,
[Min_Bal] [numeric](18, 0) NULL,
[Max_Bal] [numeric](18, 0) NULL,
[Avg_Bal] [numeric](18, 0) NULL,
[Last_Bal] [numeric](18, 0) NULL,
[PassiveDays] [int] NULL
)

INSERT INTO [Deposit_Turnover] VALUES (1,'10/20/2016 2:19:27 PM', 0 ,0, 1),
(1, '10/20/2016 2:19:27 PM' ,0 ,20 ,2),
(1, '10/21/2016 2:19:27 PM' ,15 ,0 ,1),
(2, '10/25/2016 2:19:29 PM' ,0 ,200 ,1),
(2, '10/25/2016 2:19:29 PM' ,0 ,100 ,2),
(3, '10/26/2016 2:19:29 PM' ,0 ,20 ,1),
(1, '10/26/2016 1:19:29 PM' ,5, 0 ,1);



create function dbo.gre0(@val1 float, @val2 float)
returns float
as begin 
	if ISNULL(@val1, 0) <> 0 and ISNULL(@val2, 0) <> 0
		if @val1 < @val2 
			return @val2
		if @val1 > @val2 
			return @val1
	if ISNULL(@val1, 0) = 0 and ISNULL(@val2, 0) <> 0
		return @val2
	if ISNULL(@val1, 0) <> 0 and ISNULL(@val2, 0) = 0
		return @val1
	return 0
end


CREATE PROCEDURE stpUpdateMemberBy
AS  
BEGIN
with W([depositkey],
	    [turn_time],
	    [turn_id],
	    [turnover_bed],
	    [turnover_bes], v1, v2) as (select 
	    [depositkey],
		[turn_time],
		[turn_id],
		[turnover_bed],
		[turnover_bes],
		sum([turnover_bes]) over (partition by [depositkey] order by [turn_time], [turn_id] rows unbounded preceding) as best,
		-sum([turnover_bed]) over (partition by [depositkey] order by [turn_time], [turn_id] rows unbounded preceding) as bedeh
		from [Deposit_Turnover]
										),
W2([depositkey],
	accuratedate,
	[turnover_bed],
	[turnover_bes],
	[turn_id],
	v)  as ( select
		[depositkey],
		convert(date, [turn_time]) as accuratedate,
		[turnover_bed],
		[turnover_bes],
		[turn_id],
		v1+v2
		from W),


W3([depositkey],
	accuratedate,
	lag, 
	[min], 
	[max], 
	mand, 
	v) as (select distinct [depositkey],accuratedate,
			LAG(v, 1) over (partition by [depositkey] order by accuratedate),
			min(v) over (partition by accuratedate order by accuratedate),
			max(v) over (partition by accuratedate order by accuratedate)  as [max],
			LAST_VALUE(v) over (partition by accuratedate, [depositkey] order by accuratedate desc),
			v
			from W2
			where [turn_id] <> 0
			union 
			select distinct [depositkey],accuratedate,
			LAG(v, 1) over (partition by [depositkey] order by accuratedate),
			min(v) over (partition by accuratedate order by accuratedate),
			max(v) over (partition by accuratedate order by accuratedate)  as [max],
			LAST_VALUE(v) over (partition by accuratedate, [depositkey] order by accuratedate desc),
			v
			from W2
			where [turn_id] =0),

W4([depositkey], accuratedate, [min], [max],mean, mand) as (select distinct 
	[depositkey], accuratedate, [min], dbo.gre0([max], lag),
	( [min]+ dbo.gre0([max], lag))/2, mand from W3)

--insert into [FactDeposit] ([depositkey],[Effdate],[Min_Bal],[Max_Bal],[Avg_Bal],[Last_Bal],[PassiveDays]) 
select * from W4  

END


declare @i int
declare @numrows int
SET @i = (SELECT Min([depositkey]) FROM [Deposit_Turnover])
SET @n = (SELECT Max([depositkey]) FROM [Deposit_Turnover])

    WHILE (@i <= @n)
    BEGIN

with d(date) as (
  select cast('10/20/2016' as datetime)
  union all
  select date+1
  from d , [Deposit_Turnover]
  where date < '10/26/2016'
  )

INSERT  INTO [Deposit_Turnover] ([depositkey], [turn_time], [turnover_bed],[turnover_bes],[turn_id])
select  @i , d.date, 0 , 0 ,isnull([turn_id], 0)
from d
full join perid3(@i) t
       on convert(date,t.[turn_time]) = convert(date,d.date)
where [turn_id] IS NULL
order by d.date 
        SET @i = @i + 1
    END

CREATE FUNCTION perid3 (@id2 int)  

RETURNS TABLE  
AS  
RETURN   
(  
    SELECT [turn_time], [turnover_bed],[turnover_bes],[turn_id]
	from [Deposit_Turnover] 
	where [turn_id]=@id2
);  
GO  