CREATE TABLE CoustDim2 (
	S_key int identity,
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255),
	[start_date] date,
	finish_date date,
	flag binary
	PRIMARY KEY (S_key),
	);


CREATE TABLE Temp3 (
	S_key int,
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255),
	[start_date] date,
	finish_date date,
	flag binary
	);

CREATE TABLE Temp4 (
	S_key int,
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255),
	[start_date] date,
	finish_date date,
	flag binary
	);

CREATE PROCEDURE SCD2 AS
begin

Truncate table Temp3
Truncate table Temp4

INSERT INTO Temp3 (PersonID, Name, branch, _type, mellicode, job, phone, City, info)
SELECT PersonID, Name, branch, t1._type, mellicode, job, phone, City, info
FROM Coustomer as t1
inner join Coustomertype as t2
on (t1._type=t2._type)

INSERT INTO Temp4 (PersonID, Name, branch, _type, mellicode, job, phone, City, info,[start_date],finish_date,flag)
SELECT ISnull(t2.PersonID,t1.PersonID), ISnull(t2.Name,t1.Name), ISnull(t2.branch,t1.branch), ISnull(t2._type,t1._type), ISnull(t2.mellicode,t1.mellicode), ISnull(t2.job,t1.job), ISnull(t2.phone,t1.phone), ISnull(t2.City,t1.City), ISnull(t2.info,t1.info),
case 
	when t2.PersonID <> NULL then t2.[start_date]
	else GETDATE()
end,
case 
	when t2.PersonID is NULL then NULL
	when isnull(t2.job,'0') <> t1.job and t2.flag = 1 then GETDATE()
	else t2.finish_date
end,
case 
	when t2.PersonID is NULL then 1
	when isnull(t2.job,'0') <> t1.job and t2.flag = 1 then 0
	else t2.flag
end

FROM Temp3 as t1
full outer join CoustDim2 as t2
on (t1.PersonID=t2.PersonID)


INSERT INTO Temp4 (PersonID, Name, branch, _type, mellicode, job, phone, City, info,[start_date],finish_date,flag)
SELECT t1.PersonID, t1.Name, t1.branch, t1._type, t1.mellicode, t1.job, t1.phone, t1.City, t1.info, GETDATE(), NULL, 1
FROM Temp3 as t1
inner join CoustDim2 as t2
on (t1.PersonID=t2.PersonID)
where t1.job <> t2.job and t2.flag = 1


Truncate table CoustDim2

INSERT INTO CoustDim2(PersonID, Name, branch, _type, mellicode, job, phone, City, info, [start_date],finish_date,flag)
SELECT PersonID, Name, branch, _type, mellicode, job, phone, City, info, [start_date],finish_date,flag
FROM Temp4

end


EXEC SCD2

Select * From CoustDim2

DELETE FROM Coustomer WHERE PersonID=1;
INSERT INTO Coustomer VALUES 
(1,'Amir', 'Isfahan' ,'1', '1130397955','teacher','09133129854','Isfahan');


select * From Coustomer
