CREATE DATABASE Telecom_Team_16
GO
   
USE Telecom_Team_16
   
GO 

CREATE PROCEDURE createAllTables
AS
BEGIN
	CREATE TABLE Customer_Profile (
		nationalID INT PRIMARY KEY,
		first_name VARCHAR(50),
		last_name VARCHAR(50),
		email VARCHAR(50),
		date_of_birth DATE
	);

	CREATE TABLE Customer_Account (
		mobileNo CHAR(11) PRIMARY KEY,
		pass VARCHAR(50),
		balance DECIMAL(10, 1),
		account_type VARCHAR(50),
		start_date DATE,
		status VARCHAR(50),
		points INT DEFAULT 0,
		nationalID INT,
		CONSTRAINT Customer_Account_account_type_CHK CHECK (account_type = 'Post Paid' OR account_type = 'Prepaid' OR account_type = 'Pay_as_you_go'),
		CONSTRAINT Customer_Account_status_CHK CHECK (status = 'active' OR status = 'onhold'),
		CONSTRAINT Customer_Account_nationalID_FK FOREIGN KEY (nationalID) REFERENCES Customer_Profile(nationalID)
	);

	CREATE TABLE Service_Plan (
		planID INT PRIMARY KEY IDENTITY(1,1),
		SMS_offered INT,
		minutes_offered INT,
		data_offered INT,
		name VARCHAR(50),
		price INT,
		description VARCHAR(50)
	);

	CREATE TABLE Subscription (
		mobileNo CHAR(11),
		planID INT,
		subscription_date DATE,
		status VARCHAR(50),
		PRIMARY KEY (mobileNo, planID),
		CONSTRAINT Subscription_status_CHK CHECK (status = 'active' OR status = 'onhold'),
		CONSTRAINT Subscription_mobileNo_FK FOREIGN KEY (mobileNo) REFERENCES Customer_Account(mobileNo),
		CONSTRAINT Subscription_planID_FK FOREIGN KEY (planID) REFERENCES Service_Plan(planID)
	);

	CREATE TABLE Plan_Usage (
		usageID INT PRIMARY KEY IDENTITY(1,1),
		start_date DATE,
		end_date DATE,
		data_consumption INT,
		minutes_used INT,
		SMS_sent INT,
		mobileNo CHAR(11),
		planID INT,
		CONSTRAINT Plan_Usage_mobileNo_FK FOREIGN KEY (mobileNo) REFERENCES Customer_Account(mobileNo),
		CONSTRAINT Plan_Usage_planID_FK FOREIGN KEY (planID) REFERENCES Service_Plan(planID)
	);

	CREATE TABLE Payment (
		paymentID INT PRIMARY KEY IDENTITY(1,1),
		amount DECIMAL(10,1),
		date_of_payment	DATE,
		payment_method VARCHAR(50),
		status VARCHAR(50),
		mobileNo CHAR(11),
		CONSTRAINT Payment_payment_method_CHK CHECK (payment_method = 'cash' OR payment_method = 'credit'),
		CONSTRAINT Payment_status_CHK CHECK (status = 'successful' OR status = 'pending' OR status = 'rejected'),
		CONSTRAINT Payment_mobileNo_FK FOREIGN KEY (mobileNo) REFERENCES Customer_Account(mobileNo)
	);

	CREATE TABLE Process_Payment (
		paymentID INT PRIMARY KEY,
		planID INT,
		remaining_balance AS dbo.calculate_remaining_balance(paymentID, planID),
		extra_amount AS dbo.calculate_extra_amount(paymentID, planID),
		CONSTRAINT Process_Payment_paymentID_FK FOREIGN KEY (paymentID) REFERENCES Payment(paymentID),
		CONSTRAINT Process_Payment_planID_FK FOREIGN KEY (planID) REFERENCES Service_Plan(planID)
	);

	CREATE TABLE Wallet (
		walletID INT PRIMARY KEY IDENTITY(1,1),
		current_balance DECIMAL(10,2),
		currency VARCHAR(50),
		last_modified_date DATE,
		nationalID INT,
		mobileNo CHAR(11),
		CONSTRAINT Wallet_nationalID_FK FOREIGN KEY (nationalID) REFERENCES Customer_Profile(nationalID)
	);

	CREATE TABLE Transfer_Money (
		transferID INT IDENTITY(1, 1),
		walletID1 INT,
		walletID2 INT,
		amount DECIMAL(10, 2),
		transfer_date DATE
		PRIMARY KEY (walletID1, walletID2, transferID),
		CONSTRAINT Transfer_Money_walletID1_FK FOREIGN KEY (walletID1) REFERENCES Wallet(walletID),
		CONSTRAINT Transfer_Money_walletID2_FK FOREIGN KEY (walletID2) REFERENCES Wallet(walletID)
	);

	CREATE TABLE Benefits (
		benefitID INT PRIMARY KEY IDENTITY(1,1),
		description VARCHAR(50),
		validity_date DATE,
		status VARCHAR(50),
		mobileNo CHAR(11)
		CONSTRAINT Benefits_mobileNo_FK REFERENCES Customer_Account(mobileNo)
	);

	CREATE TABLE Points_Group (
		pointID INT IDENTITY(1,1),
		benefitID INT,
		pointsAmount INT,
		paymentID INT,
		PRIMARY KEY (pointID, benefitID),
		CONSTRAINT Points_Group_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
		CONSTRAINT Points_Group_paymentID_FK FOREIGN KEY (paymentID) REFERENCES Payment(paymentID)
	);

	CREATE TABLE Exclusive_Offer (
		offerID INT IDENTITY(1,1),
		benefitID INT,
		internet_offered INT,
		SMS_offered INT,
		minutes_offered INT,
		PRIMARY KEY (offerID, benefitID),
		CONSTRAINT Exclusive_Offer_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID)
	);

	CREATE TABLE Cashback (
		cashbackID INT IDENTITY(1,1),
		benefitID INT,
		walletID INT,
		amount INT,
		credit_date DATE,
		PRIMARY KEY (cashbackID, benefitID),
		CONSTRAINT Cashback_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
		CONSTRAINT Cashback_walletID_FK FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
	);

	CREATE TABLE Plan_Provides_Benefits (
		benefitID INT,
		planID INT,
		PRIMARY KEY (benefitID, planID),
		CONSTRAINT Plan_Provides_Benefits_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
		CONSTRAINT Plan_Provides_Benefits_planID_FK FOREIGN KEY (planID) REFERENCES Service_Plan(planID) 
	);

	CREATE TABLE Shop (
		shopID INT PRIMARY KEY IDENTITY(1, 1),
		name VARCHAR(50),
		category VARCHAR(50)
	);

	CREATE TABLE Physical_Shop (
		shopID INT PRIMARY KEY,
		address VARCHAR(50),
		working_hours VARCHAR(50)
		CONSTRAINT Physical_Shop_shopID_FK FOREIGN KEY (shopID) REFERENCES Shop(shopID)
	);

	CREATE TABLE E_Shop (
		shopID INT PRIMARY KEY,
		url	VARCHAR(50),
		rating INT,
		CONSTRAINT E_Shop_shopID_FK FOREIGN KEY (shopID) REFERENCES Shop(shopID)
	);

	CREATE TABLE Voucher (
		voucherID INT PRIMARY KEY IDENTITY(1, 1),
		value INT,
		expiry_date DATE,
		points INT,
		mobileNo CHAR(11),
		shopID INT,
		redeem_date DATE,
		CONSTRAINT Voucher_mobileNo_FK FOREIGN KEY (mobileNo) REFERENCES Customer_Account(mobileNo),
		CONSTRAINT Voucher_shopID_FK FOREIGN KEY (shopID) REFERENCES Shop(shopID)
	);

	CREATE TABLE Technical_Support_Ticket (
		ticketID INT PRIMARY KEY IDENTITY(1, 1),
		mobileNo CHAR(11),
		issue_description VARCHAR(50),
		priority_level INT,
		status VARCHAR(50),
		CONSTRAINT Technical_Support_Ticket_status_CHK CHECK (status = 'Open' OR status = 'In Progress' OR status = 'Resolved'),
		CONSTRAINT Technical_Support_Ticket_mobileNo_FK FOREIGN KEY (mobileNo) REFERENCES Customer_Account(mobileNo)
	);
END

GO

CREATE FUNCTION calculate_remaining_balance (@paymentID INT, @planID INT)
RETURNS INT
AS
BEGIN
	DECLARE @amount INT, @price INT
	SELECT @amount = Payment.amount, @price = Service_Plan.price FROM Process_Payment
	INNER JOIN Payment ON @paymentID = Payment.paymentID 
	INNER JOIN Service_Plan ON @planID = Service_Plan.planID
	IF @amount > @price
		RETURN @amount - @price
	RETURN 0
END

GO

CREATE FUNCTION calculate_extra_amount (@paymentID INT, @planID INT)
RETURNS INT
AS
BEGIN
	DECLARE @amount INT, @price INT
	SELECT @amount = Payment.amount, @price = Service_Plan.price FROM Process_Payment
	INNER JOIN Payment ON @paymentID = Payment.paymentID 
	INNER JOIN Service_Plan ON @planID = Service_Plan.planID
	IF @price > @amount
		RETURN @price - @amount
	RETURN 0
END

GO

CREATE PROCEDURE clearAllTables
AS
BEGIN
	DELETE FROM Customer_Profile;
	DELETE FROM Customer_Account;
	DELETE FROM Service_Plan;
	DELETE FROM Subscription;
	DELETE FROM Plan_Usage;
	DELETE FROM Payment;
	DELETE FROM Process_Payment;
	DELETE FROM Wallet;
	DELETE FROM Transfer_Money;
	DELETE FROM Benefits;
	DELETE FROM Points_Group;
	DELETE FROM Exclusive_Offer;
	DELETE FROM Cashback;
	DELETE FROM Plan_Provides_Benefits;
	DELETE FROM Shop;
	DELETE FROM Physical_Shop;
	DELETE FROM E_Shop;
	DELETE FROM Voucher;
	DELETE FROM Technical_Support_Ticket;

END

GO

CREATE PROCEDURE dropAllTables
AS
BEGIN
	DROP TABLE Technical_Support_Ticket;
	DROP TABLE Voucher;
	DROP TABLE E_Shop;
	DROP TABLE Physical_Shop;
	DROP TABLE Shop;
	DROP TABLE Plan_Provides_Benefits;
	DROP TABLE Cashback;
	DROP TABLE Exclusive_Offer;
	DROP TABLE Points_Group;
	DROP TABLE Benefits;
	DROP TABLE Transfer_Money;
	DROP TABLE Wallet;
	DROP TABLE Process_Payment;
	DROP TABLE Payment;
	DROP TABLE Plan_Usage;
	DROP TABLE Subscription;
	DROP TABLE Service_Plan;
	DROP TABLE Customer_Account;
	DROP TABLE Customer_Profile;
END
GO


CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
	DROP PROCEDURE createAllTables;
	DROP FUNCTION calculate_remaining_balance;
	DROP FUNCTION calculate_extra_amount;
	DROP PROCEDURE clearAllTables;
	DROP PROCEDURE dropAllTables;
END
GO

CREATE VIEW allCustomerAccounts AS
SELECT * FROM Customer_Profile P JOIN Customer_Account A ON P.national_id = A.national_id; 

GO

CREATE VIEW allServicePlans AS
SELECT * FROM Service_Plan;

GO

CREATE VIEW allBenefits AS
SELECT * From Benefits B 
WHERE B.status = 'active';

GO

CREATE VIEW accountPayments AS
Select * FROM Payments P JOIN Customer_Account A ON P.mobileNo = A.mobileNo;

GO

CREATE VIEW allShops AS
	SELECT * FROM Shop;

GO

CREATE VIEW allResolvedTickets AS
	SELECT * FROM Technical_Support_Ticket
		WHERE status = 'Resolved';

GO

CREATE VIEW CustomerWallet AS
	SELECT W.*, CONCAT(C.firstName, ' ', C.lastName) AS customerName
		FROM Wallet W
			JOIN Customer_Profile C ON W.nationalID = C.nationalID;
GO

CREATE VIEW E_shopVouchers AS
	SELECT E.*, V.voucherId, V.value
		FROM E_shops E
			JOIN Voucher V ON E.shopId = V.shopId;
			
GO

CREATE VIEW PhysicalStoreVouchers AS
	SELECT P.*, V.voucherId, V.value
		FROM Physical_Shop P
			JOIN Voucher V ON P.storeId = V.storeId;
			

GO 

CREATE VIEW Num_of_cashback AS
	SELECT W.walletId, COUNT(C.cashbackID) AS cashbackCount
		FROM Wallet W
			JOIN Cashback C ON W.walletId = T.walletId
					GROUP BY W.walletId;
GO

 -------------------------------------------------------------------------------tofy---
 exec dbo.createAllTables
 
 CREATE ROLE Admin;

 GO
 CREATE PROCEDURE Account_Plan 
	AS
	BEGIN
	SELECT c.mobileNo , sp.planID
		FROM Customer_Account c, Service_Plan sp, Subscription su
			WHERE c.mobileNo = su.mobileNo AND sp.planID = su.planID;
	END

EXEC Account_Plan
GO

CREATE Function Account_Plan_date (@Subscription_Date date, @Plan_id int)
returns TABLE
AS
RETURN(
	SELECT c.mobileNo, sp.name , sp.planID
	FROM Customer_Account c, Service_Plan sp, Subscription s
	WHERE c.mobileNo = s.mobileNo AND sp.planID = s.planID
	AND s.planID = @Plan_id AND s.subscription_date = @Subscription_Date
);
GO

SELECT * FROM dbo.Account_Plan_date('2022-01-01', 3);
GO

CREATE FUNCTION Account_Usage_Plan (@MobileNo char(11),@from_date date)
returns TABLE
AS
RETURN(
		SELECT p.planID , p.data_consumption,p.minutes_used, p.SMS_sent
		FROM Plan_Usage p
		WHERE p.mobileNo = @MobileNo AND p.start_date = @from_date
);
GO

SELECT * FROM dbo.Account_Usage_Plan('01033108747','2022-01-01');

GO

CREATE PROCEDURE Benefits_Account (@MobileNo char(11),@planID int)

	AS

	BEGIN

	delete FROM Plan_Provides_Benefits WHERE exists(
		SELECT  1
		FROM Plan_Provides_Benefits p
		INNER JOIN benefits b on b.benefitID = p.benefitID
		WHERE Plan_Provides_Benefits.planID = @planID AND Benefits.mobileNo = @MobileNo
		)

	END

GO

--i dont get when an offer is of type SMS
CREATE FUNCTION Account_SMS_Offers (@MobileNo char(11))
RETURNS TABLE
AS
RETURN(
		SELECT e.SMS_offered
		FROM Exclusive_Offer e
			INNER JOIN Benefits b ON b.benefitID = e.benefitID
		WHERE b.mobileNo=@MobileNo AND e.internet_offered=0 AND e.minutes_offered=0
		

);

GO
SELECT * FROM dbo.Account_SMS_Offers('01033108747');
GO


-- are accepeted payments those that are in the payments table or the process_payment table
-- i think i cooked here 🙌
CREATE PROCEDURE Account_Payment_Points (
@MobileNo char(11),
@Payment_Count INT OUTPUT,
@Points_Count INT OUTPUT
)
AS
BEGIN
	SELECT @Payment_Count = count(*)
	FROM Payment p
	where p.mobileNo = @MobileNo AND p.date_of_payment >= DATEADD(YEAR, -1, GETDATE())

	SELECT @Points_Count = sum(p.pointsAmount)
	from Points_Group p
		INNER JOIN Benefits b on b.benefitID = p.benefitID
	where b.mobileNo = @MobileNo;
END

GO


DECLARE @TotalTransactions INT;
DECLARE @TotalPoints INT;

EXEC Account_Payment_Points 
    @MobileNo = '01033108747', 
    @Payment_Count = @TotalTransactions OUTPUT, 
    @Points_Count = @TotalPoints OUTPUT;

SELECT @TotalTransactions AS TotalTransactions, 
       @TotalPoints AS TotalPoints;


GO

--i have no idea how to do this,
CREATE FUNCTION Wallet_Cashback_Amount(@WalletId int,@planId int)
returns int
AS
BEGIN
	DECLARE @Cashback_Amount int
	select @Cashback_Amount = c
	from Cashback c
return @cashback_Amount
END


GO


CREATE FUNCTION calculate_extra_amount (@paymentID INT, @planID INT)
RETURNS INT
AS
BEGIN
	DECLARE @amount INT, @price INT
	SELECT @amount = Payment.amount, @price = Service_Plan.price FROM Process_Payment
	INNER JOIN Payment ON @paymentID = Payment.paymentID 
	INNER JOIN Service_Plan ON @planID = Service_Plan.planID
	IF @price > @amount
		RETURN @price - @amount
	RETURN 0
END

GO

--made the average a decimal because im skibidi sigma like that
--im assuming that "Sent transaction amounts" means that we are working with WalletID 1 and not 2
ALTER FUNCTION Wallet_Transfer_Amount (@Wallet_id int,@start_date date,@end_date date)
returns DECIMAL(10,2)
AS
BEGIN
	DECLARE @Transaction_Average decimal(10,2)
	SELECT @Transaction_Average = avg(t.amount)
	FROM Transfer_Money t
	WHERE t.walletID1 = @Wallet_id AND t.transfer_date BETWEEN @start_date AND @end_date;
return @Transaction_Average
END
GO

SELECT dbo.Wallet_Transfer_Amount(2, '2022-01-01', '2021-01-01') as those_who_know;


GO

CREATE FUNCTION Wallet_MobileNo (@MobileNo char(11))
returns bit
AS
BEGIN
	DECLARE @Output_Bit BIT 
	IF EXISTS( 
		SELECT 1 
		FROM Wallet t 
		WHERE t.mobileNo = @MobileNo
		) 
	BEGIN 
		SET @Output_Bit = 1;
	END 
	ELSE
		BEGIN 
			SET @Output_Bit = 0;
		END 
			RETURN @Output_Bit; 
END

GO
	
SELECT dbo.Wallet_MobileNo('01033108747') as result;

GO

-- i am not confindent in connecting Mobile NO. with points using payment
CREATE FUNCTION Total_Points_Account (@MobileNo char(11))
returns int
AS
BEGIN
DECLARE @Sum INT
	SELECT @sum = sum(pg.pointsAmount)
	FROM Payment p
		inner join Points_Group pg on pg.paymentID = p.paymentID
	where p.mobileNo = @MobileNo
return @sum
END;

GO

select dbo.Total_Points_Account('01033108747') as Dokki;



---------------------------------------------------------- Ali
GO
CREATE FUNCTION AccountLoginValidation (@MobileNo CHAR(11), @password VARCHAR(50))
RETURNS BIT
AS
BEGIN
IF EXISTS (
	SELECT *
	FROM Customer_Account
	WHERE @MobileNo = mobileNo AND @password = pass
) RETURN 1

RETURN 0
END

GO

CREATE PROCEDURE Unsubscribed_Plans 
@MobileNo CHAR(11)
AS
SELECT SP.planID
FROM Service_Plan SP WHERE NOT EXISTS (
	SELECT * 
	FROM Subscription S
	WHERE S.planID = SP.planID AND @MobileNo = mobileNo
)

GO

-- slightly unsure about this one, but will keep it like this for now - Ali
CREATE FUNCTION Consumption (@Plan_Name VARCHAR(50), @start_date DATE, @end_date DATE)
RETURNS TABLE
AS
RETURN (
	SELECT SUM(data_consumption) AS total_data, SUM(minutes_used) AS total_minutes, SUM(SMS_sent) AS total_SMS
	FROM Plan_Usage
	WHERE start_date BETWEEN @start_date AND @end_date AND end_date BETWEEN @start_date AND @end_date
)

GO

-- unsure about what dates im supposed to compare with - Ali
CREATE FUNCTION Usage_Plan_CurrentMonth (@MobileNo CHAR(11))
RETURNS TABLE
AS
RETURN (
	SELECT PU.data_consumption, PU.minutes_used, PU.SMS_sent
	FROM Plan_Usage PU
	INNER JOIN Subscription S ON S.planID = PU.planID
	WHERE @MobileNo = PU.mobileNo AND S.status = 'active' AND MONTH(S.subscription_date) = MONTH(GETDATE())
)

GO

-- unsure what columns we're actually supposed to return - Ali
CREATE FUNCTION Cashback_Wallet_Customer (@NationalID INT)
RETURNS TABLE
AS
RETURN (
	SELECT C.cashbackID, C.amount
	FROM Cashback C
	INNER JOIN Wallet W ON W.walletID = C.walletID
	WHERE @NationalID = W.nationalID
)
GO

CREATE FUNCTION Ticket_Account_Customer (@NationalID INT)
RETURNS INT
AS
BEGIN
RETURN (
	SELECT COUNT(*)
	FROM Technical_Support_Ticket T
	INNER JOIN Customer_Account C ON T.mobileNo = C.mobileNo
	WHERE T.status <> 'resolved' AND @NationalID = C.nationalID
)
END



---------------------------------------------------------------------------------tofy #2
GO

CREATE PROCEDURE Account_Highest_Voucher (
@MobileNo char(11),
@Voucher_id int OUTPUT
)
AS
BEGIN
	SELECT @Voucher_id = max(v.value)
	FROM Voucher v
	where v.mobileNo = @MobileNo;
END

DECLARE @Voucher_idd int

Exec Account_Highest_Voucher
	@MobileNo = '01033108747',
	@Voucher_id = @Voucher_idd OUTPUT;

SELECT @Voucher_idd as voucher_id;

GO


-- i dont know what they mean by 'remaining amount', remaining what? data? minutes? SMS?
CREATE FUNCTION Remaining_plan_amount (@MobileNo char(11),@plan_name varchar(50))
returns int
AS
BEGIN
	DECLARE @Remainder int
	DECLARE @T1 int
	DECLARE @T2 int

	SELECT @T1 = s.data_offered , @T2 = p.data_consumption
	from Service_Plan s
		INNER JOIN Plan_Usage p on p.planID = s.planID
	where s.name = @plan_name AND p.mobileNo = @MobileNo;

SET @Remainder = @T1 - @T2
return @Remainder

END;

GO

SELECT dbo.Remaining_plan_amount ('01033108747','DIDDY_PARTY') as QUANDALE_DINGLE; 

GO

--im not confindent in which tables i used
CREATE FUNCTION Extra_plan_amount (@MobileNo char(11),@plan_name varchar(50))
returns int
AS
BEGIN
	DECLARE @Extra_Amount int
	SELECT @Extra_Amount = pp.extra_amount
	from Payment pa
		INNER JOIN Process_Payment pp on pp.paymentID = pa.paymentID
		INNER JOIN Service_Plan sp on sp.planID = pp.planID
	where sp.name = @plan_name AND pa.mobileNo = @MobileNo
return @Extra_Amount
END

GO
SELECT dbo.Extra_plan_amount ('01033108747','Livvy Dunn') as zaflat;


GO
CREATE PROCEDURE Top_Successful_Payments (@MobileNo char(11))
AS
	SELECT TOP 10 p.amount
	FROM Payment p
	where p.mobileNo = @MobileNo
	Order by p.amount desc;


EXEC Top_Successful_Payments '01033108747';

GO






