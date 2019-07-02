-- 
-----------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE name = N'MTGDatabase')
	CREATE DATABASE MTGdatabase
GO
USE MTGdatabase
--
-- Alter the path so the script can find the CSV files 
--
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = 'E:\Class\GitHub\';
--
-- Delete existing tables
--
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Paradox_Engine_Price'
       )
	DROP TABLE Paradox_Engine_Price;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'TCG_Player_Decks'
       )
	DROP TABLE TCG_Player_Decks;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'CEDH_Decklists'
       )
	DROP TABLE CEDH_Decklists;
--
	IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'BurnJPW'
       )
	DROP TABLE BurnJPW;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Card_list'
       )
	DROP TABLE Card_List;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Set_Release'
		)
	DROP TABLE Set_Release
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'CEDH_deck_Creator_info'
       )
	DROP TABLE CEDH_Deck_Creator_Info;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'SCG_Modern_Tournament'
       )
	DROP TABLE SCG_Modern_Tournament;
--

--
-- Create tables
--
CREATE TABLE SCG_Modern_Tournament
(	Place	INT,
	Deck_Name	NVARCHAR(30),
	Pilot		NVARCHAR(30),
	OnlinePrice	INT,
	PaperPrice	INT,
	TournamentDate	DATE
	--Constraint pk_deck_pilot PRIMARY KEY (Deck_Name, Pilot)
);
--
CREATE TABLE CEDH_Deck_Creator_Info
(	DeckName	NVARCHAR(50) CONSTRAINT pk_deck_name PRIMARY KEY,
	CreatedDate	DATE,
	LastUpdated	DATE,
	CreatorName	NVARCHAR(50) CONSTRAINT nn_creator_name NOT NULL
);
--

CREATE TABLE Set_Release
(	set_abbr		NVARCHAR(6),
	set_name		NVARCHAR(60) CONSTRAINT pk_set_name PRIMARY KEY,
	set_type		NVARCHAR(30),
	released_at		Date
);
--
CREATE TABLE Card_List 
(	card_name		NVARCHAR(60) CONSTRAINT pk_card_name PRIMARY KEY,		
	mana_cost		NVARCHAR(20),
	cmc				INT,
	type_line		NVARCHAR(90),
	oracle_text		NVARCHAR(MAX),
	colors			NVARCHAR(1),
	color_identity	NVARCHAR(1),
	standard		NVARCHAR(10),
	future			NVARCHAR(10),
	frontier		NVARCHAR(10),
	modern			NVARCHAR(10),
	legacy			NVARCHAR(10),
	pauper			NVARCHAR(10),
	vintage			NVARCHAR(10),
	penny			NVARCHAR(10),
	commander		NVARCHAR(10),
	duel			NVARCHAR(10),
	setAbbr			NVARCHAR(5),
	set_name		NVARCHAR(60),-- CONSTRAINT fk_set_name REFERENCES Set_Release(set_name),
	set_type		NVARCHAR(30),
	collector_number	INT,
	rarity			NVARCHAR(10),
	artist			NVARCHAR(50)
	);
--
CREATE TABLE BurnJPW
(	Board			NVARCHAR(5),
	QTY				INT,
	Card_Name		NVARCHAR(60), -- Constraint
	Deck_Name		NVARCHAR(30),
	Pilot			NVARCHAR(30)
	--Constraint pk_deck_pilot References Tournament(deck_pilot)

);
--
CREATE TABLE TCG_Player_Decks 
	(DeckName		NVARCHAR(100) CONSTRAINT nn_DeckName NOT NULL,
	 PlayerName		NVARCHAR(50) CONSTRAINT nn_PlayerName NOT NULL,
	 TCG_Date		Date  CONSTRAINT nn_CreationDate NOT NULL
	);
--
CREATE TABLE CEDH_Decklists 
	(deck_name	NVARCHAR(50),-- CONSTRAINT fk_DeckName REFERENCES CEDH_Deck_Creator_Info(DeckName),
	 board		NVARCHAR(6) CONSTRAINT nn_Board NOT NULL,
	 qty		INT,
	 card_name	NVARCHAR(60),
	 legal_format		NVARCHAR(15),
   --CONSTRAINT fk_card_name_cedh REFERENCES Card_List(card_name)
	);
--
CREATE TABLE Paradox_Engine_Price 
(	Date			DATE NOT NULL,
	card_name		NVARCHAR(60),-- CONSTRAINT fk_card_name REFERENCES Card_List(card_name),
	set_name			NVARCHAR(30),
	set_abbr			NVARCHAR(3),	
	paperPrice		MONEY,
	onlinePrice		MONEY,
	foilPaperPrice	MONEY,
	foilOnlinePrice	MONEY
	);
--
-- Load table data
--

--Compiles
EXECUTE (N'BULK INSERT Paradox_Engine_Price FROM ''' + @data_path + N'ParadoxEnginePrice.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--Untested
EXECUTE (N'BULK INSERT SCG_Modern_Tournament FROM ''' + @data_path + N'SCG_ModernClassic.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');

--Compiles
EXECUTE (N'BULK INSERT BurnJPW FROM ''' + @data_path + N'SCGPittBurnJPW.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--Compiles
EXECUTE (N'BULK INSERT Set_Release FROM ''' + @data_path + N'Set Release Dates.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
-- Compiles
EXECUTE (N'BULK INSERT CEDH_Deck_Creator_Info FROM ''' + @data_path + N'CEDH deck creation info.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');

--
--Compiles
EXECUTE (N'BULK INSERT CEDH_Decklists FROM ''' + @data_path + N'CEDHDecklists.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');


--Compiles
EXECUTE (N'BULK INSERT Card_List FROM ''' + @data_path + N'MTGSimpleCardList.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');

--Compiles
EXECUTE (N'BULK INSERT TCG_Player_Decks FROM ''' + @data_path + N'TCGDecksWParadoxEngine.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');



--

--

--
-- Verify Row Count in Tables.
GO
SET NOCOUNT ON
SELECT 'CEDH_Deck_Creator_Info'  AS "Table",COUNT(*) AS "CEDH_Deck_Creator_Info" FROM CEDH_Deck_Creator_Info	UNION
SELECT 'Set_Release',						COUNT(*) FROM Set_Release UNION
SELECT 'TCG_Player_Decks',					COUNT(*) FROM TCG_Player_Decks	UNION
SELECT 'CEDH_Decklists',					COUNT(*) FROM CEDH_Decklists	UNION
SELECT 'Paradox_Engine_Price',				COUNT(*) FROM Paradox_Engine_Price	UNION
SELECT 'Card_list',							COUNT(*) FROM Card_List		UNION
SELECT 'SCG_ModernTournament',				COUNT(*) FROM SCG_Modern_Tournament UNION
SELECT 'BurnJPW',							COUNT(*) FROM BurnJPW
ORDER BY 1;
SET NOCOUNT OFF
GO
-- END OF SCRIPT
