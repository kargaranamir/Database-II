CREATE TABLE Coustomer (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(255),
    City varchar(255),
	PRIMARY KEY (PersonID),
	FOREIGN KEY (_type) REFERENCES Coustomertype(_type)
);

CREATE TABLE Coustomertype (
	_type varchar(255),
	info varchar(255)
	PRIMARY KEY (_type),
	);

CREATE TABLE CoustDim (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255)
	);

INSERT INTO Coustomer VALUES 
(1,'Amir', 'Isfahan' ,'1', '1130397955','student','09133129854','Isfahan'),
(2,'Hosssein', 'Tehran' ,'1', '1220399855','teacher','09123559854','Tabriz'),
(3,'Mahdi', 'Tabriz' ,'2', '5555397955','engineer','09136669854','Tehran'),
(4,'Ali', 'Shiraz' ,'3', '2220498955','nurse','09133120889','Shiraz'),
(5,'Akbar', 'Mashhad' ,'2', '5630397955','doctor','09247229889','Tehran'),
(6,'Mohammad', 'Semnan' ,'1', '9870398066','supervisor','09144120066','Tehran');



INSERT INTO Coustomertype VALUES 
('1', 'first class'),
('2','second calss'),
('3','third class');

CREATE TABLE Temp1 (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255)
	);

CREATE TABLE Temp2 (
    PersonID int,
    Name varchar(255),
    branch varchar(255),
	_type varchar(255),
	mellicode varchar(10),
	job varchar(255),
    phone varchar(11),
    City varchar(255),
	info varchar(255)
	);

CREATE PROCEDURE SCD1 AS
begin

Truncate table Temp1
Truncate table Temp2

INSERT INTO Temp1 (PersonID, Name, branch, _type, mellicode, job, phone, City, info)
SELECT PersonID, Name, branch, t1._type, mellicode, job, phone, City, info
FROM Coustomer as t1
inner join Coustomertype as t2
on (t1._type=t2._type)

INSERT INTO Temp2 (PersonID, Name, branch, _type, mellicode, job, phone, City, info)
SELECT ISnull(t1.PersonID,t2.PersonID), ISnull(t1.Name,t2.Name), ISnull(t1.branch,t2.branch), ISnull(t1._type,t2._type), ISnull(t1.mellicode,t2.mellicode), ISnull(t1.job,t2.job), ISnull(t1.phone,t2.phone), ISnull(t1.City,t2.City), ISnull(t1.info,t2.info)
FROM Temp1 as t1
full outer join CoustDim as t2
on (t1.PersonID=t2.PersonID)

Truncate table CoustDim

INSERT INTO CoustDim (PersonID, Name, branch, _type, mellicode, job, phone, City, info)
SELECT PersonID, Name, branch, _type, mellicode, job, phone, City, info
FROM Temp2

end


EXEC SCD1

Select * From CoustDim

DELETE FROM Coustomer WHERE PersonID=1;
INSERT INTO Coustomer VALUES 
(1,'Amir', 'Isfahan' ,'1', '1130397955','teacher','09133129854','Isfahan');



