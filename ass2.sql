-- Answer to Part 1 of the 2nd Database Assignment 2020/21
--
-- CANDIDATE NUMBER: 220882
-- Please insert your candidate number in the line above.
-- Do NOT remove ANY lines of this template.

-- In each section below put your answer in a new line 
-- BELOW the corresponding comment.
-- Use ONE SQL statement ONLY per question.
-- If you don’t answer a question just leave 
-- the corresponding space blank. 
-- Anything that does not run in SQL you MUST put in comments.

-- DO NOT REMOVE ANY LINE FROM THIS FILE.

-- START OF ASSIGNMENT CODE


-- @@01

CREATE TABLE MoSpo_HallOfFame (
hoFdriverId INTEGER UNSIGNED NOT NULL,
hoFYear DECIMAL(4,0) CHECK ((hoFYear>1901 AND hoFYear<2155) OR hoFYear=0000) NOT NULL,
hoFSeries ENUM('BritishGT','Formula1','FormulaE','SuperGT'), 
hoFImage VARCHAR(200),
hoFWins INT DEFAULT(0) CHECK(hoFWins<100),
hoFBestRaceName VARCHAR(30),
hoFBestRaceDate DATE,
PRIMARY KEY (hoFdriverId,hoFYear),
CONSTRAINT fk_Driver FOREIGN KEY (hoFdriverId) REFERENCES MoSpo_Driver(driverId) ON DELETE CASCADE,
CONSTRAINT fk_bestRace FOREIGN KEY (hoFBestRaceName,hoFBestRaceDate) REFERENCES MoSpo_Race(raceName,raceDate) ON DELETE SET NULL
);
 
 
-- @@02

ALTER TABLE MoSpo_Driver
ADD driverWeight FLOAT(2,1) CHECK (driverWeight>0 AND driverWeight<99.91);

-- @@03

UPDATE MoSpo_RacingTeam
SET teamPostcode = 'HP135PN' WHERE teamName ='Beechdean Motorsport';

-- @@04

DELETE FROM MoSpo_Driver
WHERE driverLastname='Senna' AND driverFirstname='Ayrton';

-- @@05

SELECT COUNT(teamName) AS numberTeams FROM MoSpo_RacingTeam;

-- @@06

SELECT driverID, CONCAT(LEFT(driverFirstname,1),' ',driverLastname) AS driverName, driverDOB
FROM MoSpo_Driver
WHERE (LEFT(driverFirstname,1)=LEFT(driverLastname,1));

-- @@07

SELECT driverTeam, COUNT(driverId) AS numberOfDriver
FROM MoSpo_Driver
GROUP BY driverTeam;

-- @@08

SELECT lapInfoRaceName AS raceName, lapInfoRaceDate AS raceDate, MIN(lapInfoTime) AS lapTime
FROM MoSpo_LapInfo
GROUP BY lapInfoRaceName, lapInfoRaceDate;

-- @@09

SELECT pitstopRaceName as raceName, AVG(totalPitStops)
FROM (SELECT pitstopRaceName, COUNT(pitstopRaceName) as totalPitStops, YEAR(pitstopRaceDate) as raceYear
FROM MoSpo_PitStop
GROUP BY pitstopRaceName, raceYear) as t
GROUP BY pitstopRaceName;

-- @@10

SELECT MoSpo_Car.carMake FROM MoSpo_RaceEntry
JOIN MoSpo_LapInfo ON MoSpo_LapInfo.lapInfoRaceName=MoSpo_RaceEntry.raceEntryRaceName AND MoSpo_LapInfo.lapInfoRaceDate=MoSpo_RaceEntry.raceEntryRaceDate AND 
MoSpo_LapInfo.lapInfoRaceNumber=MoSpo_RaceEntry.raceEntryNumber 
JOIN MoSpo_Car ON MoSpo_Car.carId = MoSpo_RaceEntry.raceEntryCarId 
WHERE (YEAR(lapInfoRaceDate)='2018' and lapInfoCompleted = '0');

-- @@11

SELECT DISTINCT pitstopRaceName AS raceName, pitstopRaceDate AS raceDate, 
CASE 
WHEN MAX(totalPitStops) OVER (PARTITION BY pitstopRaceName, pitstopRaceDate) IS NULL 
THEN '0'
ELSE MAX(totalPitStops) OVER (PARTITION BY pitstopRaceName, pitstopRaceDate) 
END AS 'mostPitstops'  FROM 
(SELECT DISTINCT pitstopRaceName,pitstopRaceDate,COUNT(*) AS totalPitStops , pitstopRaceNumber FROM MoSpo_PitStop
GROUP BY pitstopRaceName, pitstopRaceDate,pitstopRaceNumber) AS d;

-- @@12

SELECT driverId, driverLastname FROM MoSpo_Driver
LEFT JOIN MoSpo_RaceEntry ON MoSpo_Driver.driverId=MoSpo_RaceEntry.raceEntryDriverId
JOIN MoSpo_LapInfo ON MoSpo_RaceEntry.raceEntryNumber=MoSpo_LapInfo.lapInfoRaceNumber AND MoSpo_RaceEntry.raceEntryRaceName=MoSpo_LapInfo.lapInfoRaceName AND MoSpo_RaceEntry.raceEntryRaceDate=MoSpo_LapInfo.lapInfoRaceDate
WHERE raceEntryCarId IS NOT NULL OR MoSpo_LapInfo.lapInfoCompleted=1
GROUP BY driverId;

-- @@13

SELECT DISTINCT carsDistinct1 AS carMake, (retirement/raceRate) AS retirementRate FROM (
SELECT DISTINCT carMake AS carsDistinct1, COUNT(carMake) AS raceRate FROM MoSpo_Car, MoSpo_RaceEntry, MoSpo_LapInfo 
WHERE lapInfoCompleted = 0 AND YEAR(lapInfoRaceDate) = 2018 GROUP BY carMake
INNER JOIN(SELECT DISTINCT carMake AS carsDistinct2, COUNT(carMake) AS retirement FROM MoSpo_Car 
INNER JOIN MoSpo_RaceEntry ON MoSpo_Car.carID = MoSpo_RaceEntry.raceEntryCarId WHERE YEAR(raceEntryRaceDate) = 2018
GROUP BY carMake ORDER BY COUNT(carMake)) retirement
ON races.carsDistinct1 = retirement.carsDistinct2;

-- @@14


DELIMITER $$
CREATE FUNCTION totalRaceTime(racingNum INT, raceName VARCHAR(30), raceDate DATE)
RETURNS INTEGER
BEGIN
declare counter INT; 
declare errorFinder INT;
SELECT SUM(lapInfoTime) INTO counter
FROM MoSpo_LapInfo
WHERE lapInfoRaceTime=raceName AND lapInfoRaceDate=raceDate AND lapInfoRaceNumber=racingNum;
IF counter IS NULL
THEN 
SELECT COUNT(*) INTO errorFinder FROM MoSpo_LapInfo WHERE lapInfoRaceName=raceName;
RETURN counter; 
END $$


-- END OF ASSIGNMENT CODE
