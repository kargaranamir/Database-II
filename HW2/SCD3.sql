create TABLE CoustDim (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	originaljob varchar(255),
	currentjob varchar(255),
	effective_Date datetime,
    phone varchar(11),
    City varchar(255),
	info varchar(255)
	);


create TABLE Temp5 (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	originaljob varchar(255),
	currentjob varchar(255),
	effective_Date datetime,
    phone varchar(11),
    City varchar(255),
	info varchar(255)
	);


create procedure SCD3
AS
begin
truncate table Temp5

insert into Temp5
select CoustDim.PersonID, CoustDim.Name, CoustDim.branch, CoustDim._type, CoustDim.mellicode, CoustDim.originaljob as originaljob, coustomer.job as currentjob, GETDATE() as effective_Date, CoustDim.phone, CoustDim.City, CoustDim.info 
from coustomer inner join coustomertype on (coustomer._type = coustomertype._type) inner join CoustDim on (coustomer.PersonID = CoustDim.PersonID)
where coustomer.job != CoustDim.currentjob

delete from CoustDim
where PersonID in (select PersonID from Temp5)

insert into CoustDim
select * from Temp5

insert into CoustDim
select coustomer.PersonID, coustomer.Name, coustomer.branch, coustomer._type, coustomer.mellicode, coustomer.job as currentjob, coustomer.job as originaljob, GETDATE() as effective_Date, coustomer.phone, coustomer.City, coustomertype.info 
from coustomer inner join coustomertype on (coustomer._type = coustomertype._type) where PersonID not in (select PersonID from CoustDim)
end

