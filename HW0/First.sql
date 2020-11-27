CREATE Function [dbo].[udf-Stat-Sum-of-Digits12] (@Val bigint)
Returns bigint
As
Begin

Declare @RetVal as bigint 
Declare @LIN as int 
SET @LIN = len(CAST( @Val AS nvarchar))
;with i AS (
    Select @Val / 10 n, (@Val % 10)  d 
    Union ALL
    Select n / 10, (n % 10) * (@LIN - len(CAST( n AS nvarchar)) +1 )
    From i
    Where n > 0
)

Select @RetVal = SUM(d) FROM i;
Return @RetVal

END

CREATE FUNCTION dbo.ISOweek6 (@nr nvarchar(10))  
RETURNS int  
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @ISOweek int; 
	 DECLARE @nr2 nvarchar(10); 
	 DECLARE @sum bigint;
	 DECLARE @check bigint;
	 DECLARE @reminder bigint;
	 DECLARE @reminder2 bigint;

	 SET @ISOweek = 0

		IF (ISNUMERIC(@nr)=0)
		begin
			RETURN(0)
		end

		SET @nr2=@nr

		IF(len(@nr)<10)
		begin
			SET	@nr2 = REPLICATE('0', 10-Len(@nr)) + @nr ;
		end

		SET @check = CAST( RIGHT(@nr2,1 ) AS bigint)
		SET @sum = [dbo].[udf-Stat-Sum-of-Digits12](CAST( @nr2 AS bigint))-@check
		SET @reminder = @sum%11
		SET @reminder2= 11-@reminder

		IF ( ((@reminder<2) AND ( @check=@reminder)) or ((@reminder>1) AND (@reminder2=@check)) )
		begin
			SET @ISOweek = 1
		end

     RETURN(@ISOweek);  
END;  
GO  

SElect dbo.ISOweek6('0030397955')