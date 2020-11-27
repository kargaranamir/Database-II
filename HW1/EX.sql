Create FUNCTION fn_Nameret4(@in nvarchar(20), @pattern nvarchar(20))
RETURNS NVARCHAR(40)
AS
BEGIN
DECLARE @ret_Value NVARCHAR(40);
set @ret_Value= @in
while(PATINDEX('%'+@pattern +'%',@ret_Value)<>0)
begin
set @ret_Value = REPLACE(@ret_Value,@pattern,'')
end 

RETURN (@ret_Value)
End



select [dbo].[fn_Nameret4]('MSMS','MS')