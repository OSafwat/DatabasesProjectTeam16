-- 2.1a
CREATE DATABASE Telecom_Team_16
GO
   
USE Telecom_Team_16
   
GO 

-- 2.1b
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

-- 2.1c
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

-- 2.1d
CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
	DROP PROCEDURE createAllTables;
	DROP FUNCTION calculate_remaining_balance;
	DROP FUNCTION calculate_extra_amount;
	DROP PROCEDURE clearAllTables;
	DROP PROCEDURE dropAllTables;
	DROP VIEW allCustomerAccounts;
	DROP VIEW allServicePlans;
	DROP VIEW allBenefits;
	DROP VIEW accountPayments;
	DROP VIEW allShops;
	DROP VIEW allResolvedTickets;
	DROP VIEW CustomerWallet;
	DROP VIEW E_shopVouchers;
	DROP VIEW PhysicalStoreVouchers;
	DROP VIEW Num_of_cashback;
	DROP PROCEDURE Account_Plan;
	DROP FUNCTION Account_Plan_date;
	DROP FUNCTION Account_Usage_Plan;
	DROP PROCEDURE Benefits_Account;
	DROP FUNCTION Account_SMS_Offers;
	DROP PROCEDURE Account_Payment_Points;
	DROP FUNCTION Wallet_Cashback_Amount;
	DROP FUNCTION calculate_extra_amount;
	DROP FUNCTION Wallet_Transfer_Amount;
	DROP FUNCTION Wallet_MobileNo;
	DROP FUNCTION Total_Points_Account;
	DROP FUNCTION AccountLoginValidation;
	DROP PROCEDURE Unsubscribed_Plans;
	DROP FUNCTION Consumption;
	DROP FUNCTION Usage_Plan_CurrentMonth;
	DROP FUNCTION Cashback_Wallet_Customer;
	DROP FUNCTION Ticket_Account_Customer;
	DROP PROCEDURE Account_Highest_Voucher;
	DROP FUNCTION Remaining_plan_amount;
	DROP FUNCTION Extra_plan_amount;
	DROP PROCEDURE Top_Successful_Payments;
END

GO

-- 2.1e
CREATE PROCEDURE clearAllTables
AS
BEGIN
	DELETE FROM Technical_Support_Ticket
	DELETE FROM Voucher
	DELETE FROM E_Shop
	DELETE FROM Physical_Shop
	DELETE FROM Shop
	DELETE FROM Plan_Provides_Benefits
	DELETE FROM Cashback
	DELETE FROM Exclusive_Offer
	DELETE FROM Points_Group
	DELETE FROM Benefits
	DELETE FROM Transfer_Money
	DELETE FROM Wallet
	DELETE FROM Process_Payment
	DELETE FROM Payment
	DELETE FROM Plan_Usage
	DELETE FROM Subscription
	DELETE FROM Service_Plan
	DELETE FROM Customer_Account
	DELETE FROM Customer_Profile
END

GO

-- 2.2a
CREATE VIEW allCustomerAccounts AS
SELECT * FROM Customer_Profile P 
INNER JOIN Customer_Account A ON P.national_id = A.national_id; 

GO

-- 2.2b
CREATE VIEW allServicePlans AS
SELECT * FROM Service_Plan;

GO


-- 2.2c
CREATE VIEW allBenefits AS
SELECT * From Benefits B 
WHERE B.status = 'active';

GO

-- 2.2d
CREATE VIEW accountPayments AS
Select * FROM Payments P 
INNER JOIN Customer_Account A ON P.mobileNo = A.mobileNo;

GO

-- 2.2e
CREATE VIEW allShops AS
SELECT * FROM Shop;

GO


-- 2.2f
CREATE VIEW allResolvedTickets AS
SELECT * FROM Technical_Support_Ticket
WHERE status = 'Resolved';

GO


-- 2.2g
CREATE VIEW CustomerWallet AS
SELECT W.*, CONCAT(C.first_name, ' ', C.last_name) AS customerName
FROM Wallet W
INNER JOIN Customer_Profile C ON W.nationalID = C.nationalID;
GO

-- 2.2h
CREATE VIEW E_shopVouchers AS
SELECT E.*, V.voucherId, V.value
FROM E_shops E
INNER JOIN Voucher V ON E.shopId = V.shopId
WHERE V.redeem_date IS NOT NULL;
			
GO

-- 2.2i
CREATE VIEW PhysicalStoreVouchers AS
SELECT P.*, V.voucherId, V.value
FROM Physical_Shop P
INNER JOIN Voucher V ON P.shopID = V.shopID
WHERE V.redeem_date IS NOT NULL;
			

GO 

-- 2.2j
CREATE VIEW Num_of_cashback AS
SELECT W.walletId, COUNT(C.cashbackID) AS cashbackCount
FROM Wallet W
INNER JOIN Cashback C ON W.walletId = C.walletId
GROUP BY W.walletId;

GO

 -------------------------------------------------------------------------------tofy---
 exec dbo.createAllTables
 
 GO

-- 2.3a
CREATE PROCEDURE Account_Plan 
AS
BEGIN
	SELECT c.mobileNo, c.name AS customer_name, su.planID, sp.name AS plan_name
	FROM Customer_Account c
	INNER JOIN Service_Plan sp ON c.mobileNo = sp.mobileNo
	INNER JOIN Subscription su ON sp.planID = sp.planID
END

GO

-- 2.3b
CREATE FUNCTION Account_Plan_Date (@Subscription_Date DATE, @Plan_id INT)
RETURNS TABLE
AS
RETURN (
	SELECT CA.mobileNo, S.planID, SP.name AS plan_name
	FROM Customer_Account CA 
	INNER JOIN Subscription S ON S.mobileNo = CA.mobileNo
	INNER JOIN Service_Plan SP ON S.planID = SP.planID
	WHERE @Plan_id = S.planID AND @Subscription_Date = S.subscription_date
)

GO

SELECT * FROM dbo.Account_Plan_date('2022-01-01', 3);
GO

-- 2.3c
CREATE FUNCTION Account_Usage_Plan (@MobileNo CHAR(11), @from_date DATE)
RETURNS TABLE
AS
RETURN (
	SELECT planID, SUM(data_consumption) AS total_data, SUM(minutes_used) AS total_minutes, SUM(SMS_sent) AS total_SMS
	FROM Plan_Usage
	WHERE @MobileNo = mobileNo AND @from_date <= start_date
	GROUP BY planID
)

GO

SELECT * FROM dbo.Account_Usage_Plan('01033108747','2022-01-01');

GO

-- 2.3d
CREATE PROCEDURE Benefits_Account
@MobileNo CHAR(11),
@planID INT
AS
	WITH benefitsToDelete AS (
		SELECT B.benefitID AS idsToDelete
		FROM Benefits B
		INNER JOIN Plan_Provides_Benefits PB ON B.benefitID = PB.benefitID
		WHERE @MobileNo = B.mobileNo AND @planID = PB.planID
	)

	DELETE FROM Benefits
	WHERE EXISTS (
		SELECT 1
		FROM benefitsToDelete 
		WHERE benefitID = idsToDelete
	)

GO

-- 2.3e
CREATE FUNCTION Account_SMS_Offers (@MobileNo char(11))
RETURNS TABLE
AS
RETURN (
	SELECT b.benefitID, e. offerID, e.SMS_offered
	FROM Exclusive_Offer e
	INNER JOIN Benefits b ON b.benefitID = e.benefitID
	WHERE b.mobileNo = @MobileNo AND SMS_offered > 0
);

GO

SELECT * FROM dbo.Account_SMS_Offers('01033108747');

GO

-- 2.3f
CREATE PROCEDURE Account_Payment_Points
@MobileNo CHAR(11),
@TotalTransactions INT OUTPUT,
@TotalPoints INT OUTPUT
AS
	SELECT @TotalTransactions = COUNT(*), @TotalPoints = SUM(PG.pointsAmount)
	FROM Payment P
	INNER JOIN Process_Payment PP ON P.paymentID = PP.paymentID
	INNER JOIN Points_Group PG ON PG.paymentID = P.paymentID
	WHERE P.mobileNo = @MobileNo AND P.status = 'successful' AND p.date_of_payment >= DATEADD(YEAR, -1, GETDATE())


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

-- 2.3g
CREATE FUNCTION Wallet_Cashback_Amount (@WalletId INT, @PlanId INT)
RETURNS INT
AS
BEGIN
	DECLARE @CashbackReturned INT
	SELECT @CashbackReturned = SUM(C.amount) 
	FROM Cashback C
	INNER JOIN Plan_Provides_Benefits P ON P.benefitID = C.benefitID
	WHERE P.planID = @PlanId AND C.walletID = @WalletId
	RETURN @CashbackReturned
END


GO


-- 2.3h
CREATE FUNCTION Wallet_Transfer_Amount (@Wallet_id int, @start_date date, @end_date date)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Transaction_Average DECIMAL(10,2)
	SELECT @Transaction_Average = AVG(t.amount)
	FROM Transfer_Money t
	WHERE t.walletID1 = @Wallet_id AND t.transfer_date BETWEEN @start_date AND @end_date;
	RETURN @Transaction_Average
END
GO

SELECT dbo.Wallet_Transfer_Amount(2, '2022-01-01', '2021-01-01') as those_who_know;


GO

-- 2.3i
CREATE FUNCTION Wallet_MobileNo (@MobileNo char(11))
RETURNS BIT
AS
BEGIN
	DECLARE @Output_Bit BIT 
	IF EXISTS ( 
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

-- 2.3j
CREATE PROCEDURE Total_Points_Account
@MobileNo CHAR(11)
AS
	DECLARE @totalPoints INT
	SELECT @totalPoints = SUM(P.pointsAmount)
	FROM Points_Group P
	INNER JOIN Benefits B ON P.benefitID = B.benefitID
	WHERE B.mobileNo = @MobileNo

	UPDATE Customer_Account
	SET points = @totalPoints
	WHERE mobileNo = @MobileNo

GO

select dbo.Total_Points_Account('01033108747') as Dokki;


GO

---------------------------------------------------------- Ali

-- 2.4a
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

-- 2.4b
-- slightly unsure about this one, but will keep it like this for now - Ali
CREATE FUNCTION Consumption (@Plan_Name VARCHAR(50), @start_date DATE, @end_date DATE)
RETURNS TABLE
AS
RETURN (
	SELECT mobileNo, SUM(data_consumption) as total_data, SUM(minutes_used) as total_minutes, SUM(SMS_sent) AS total_SMS
	FROM Plan_Usage
	WHERE start_date >= @start_date AND end_date <= @end_date
	GROUP BY mobileNo
)

GO

-- 2.4c
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

-- 2.4d
-- unsure about what dates im supposed to compare with - Ali
CREATE FUNCTION Usage_Plan_CurrentMonth
(@MobileNo CHAR(11))
RETURNS TABLE
AS
RETURN (
	SELECT PU.data_consumption, PU.minutes_used, PU.SMS_sent
	FROM Plan_Usage PU
	INNER JOIN Subscription S ON S.planID = PU.planID
	WHERE @MobileNo = PU.mobileNo AND S.status = 'active' AND (MONTH(GETDATE()) = MONTH(PU.start_date) OR MONTH(GETDATE()) = MONTH(PU.end_date))
)

GO

-- 2.4e
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

-- 2.4f
CREATE PROCEDURE Ticket_Account_Customer 
@NationalID INT,
@SupportTickets INT OUTPUT
AS
BEGIN
	SELECT @SupportTickets = COUNT(*)
	FROM Technical_Support_Ticket T
	INNER JOIN Customer_Account C ON T.mobileNo = C.mobileNo
	WHERE T.status <> 'resolved' AND C.nationalID = @NationalID
END


GO
---------------------------------------------------------------------------------tofy #2

-- 2.4g
CREATE PROCEDURE Account_Highest_Voucher
@MobileNo CHAR(11),
@VoucherID INT OUTPUT
AS 
	DECLARE @maxValue INT
	SELECT @maxValue = MAX(value)
	FROM Voucher
	WHERE @MobileNo = mobileNo

	SELECT TOP 1 @VoucherID = voucherID
	FROM Voucher
	WHERE value = @maxValue

GO

--2.4h
-- i dont know what they mean by 'remaining amount', remaining what? data? minutes? SMS? apples? bananas? oranges? pencils?
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

-- 2.4i
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

-- 2.4j
CREATE PROCEDURE Top_Successful_Payments (@MobileNo char(11))
AS
	SELECT TOP 10 p.paymentID, p.amount, p.date_of_payment
	FROM Payment p
	where p.mobileNo = @MobileNo
	Order by p.amount desc;


GO

-- 2.4k
CREATE FUNCTION Subscribed_plans_5_Months (@MobileNo CHAR(11))
RETURNS TABLE
AS
RETURN (
	SELECT SP.planID, SP.name, S.status
	FROM Service_Plan SP
	INNER JOIN Subscription S ON S.planID = SP.planID
	WHERE S.subscription_date >= DATEADD(MONTH, -5, GETDATE()) AND S.mobileNo = @MobileNo
)

GO

-- 2.4l
CREATE PROCEDURE Initiate_plan_payment
@MobileNo CHAR(11),
@amount DECIMAL(10,1),
@payment_method VARCHAR(50),
@plan_id INT
AS
BEGIN
	INSERT INTO Payment VALUES (@amount, GETDATE(), @payment_method, 'successful', @MobileNo)
	DECLARE @payment_id INT
	SELECT @payment_id = MAX(paymentID) FROM Payment
	INSERT INTO Process_Payment VALUES (@payment_id, @plan_id)
	
	DECLARE @remaining_balance DECIMAL(10, 1)
	SELECT @remaining_balance = remaining_balance FROM Process_Payment WHERE paymentID = @payment_id

	-- what if they have extra amounts or remaining balances accumulated from previous payments? not sure how to handle
	IF @remaining_balance = 0
	BEGIN
		UPDATE Subscription
		SET status = 'active'
		WHERE planID = @plan_id AND mobileNo = @MobileNo
	END
END

GO

-- 2.4n
CREATE PROCEDURE Initiate_balance_payment
@MobileNo CHAR(11),
@amount DECIMAL(10, 1),
@payment_method VARCHAR(50)
AS
BEGIN
	INSERT INTO Payment VALUES (@amount, GETDATE(), @payment_method, 'successful', @MobileNo)
	
	UPDATE Customer_Account
	SET balance = balance + @amount
	WHERE mobileNo = @MobileNo
END

GO

-- 2.4o
CREATE PROCEDURE Redeem_voucher_points
@MobileNo CHAR(11),
@voucher_id INT
AS
	DECLARE @userPoints INT 
	SELECT @userPoints = points
	FROM Customer_Account
	WHERE mobileNo = @MobileNo

	DECLARE @voucherPoints INT
	SELECT @voucherPoints = points
	FROM Voucher 
	WHERE voucherID = @voucher_id

	IF EXISTS (
		SELECT 1 
		FROM Voucher 
		WHERE voucherID = @voucher_id AND GETDATE() < expiry_date AND redeem_date IS NULL
	) AND @userPoints >= @voucherPoints
	BEGIN
		UPDATE Voucher 
		SET mobileNo = @MobileNo, redeem_date = GETDATE()
		WHERE voucherID = @voucher_id

		UPDATE Customer_Account
		SET points = points - @voucherPoints
		WHERE mobileNo = @MobileNo
	END

----------------------------------------------------Gemini
exec dbo.dropAllTables
Exec dbo.createAllTables


INSERT INTO Customer_profile (nationalID, first_name, last_name, email, date_of_birth)
VALUES
  (0234567890, 'John', 'Doe', 'johndoe@email.com', '1990-01-01'),
  (0076543210, 'Jane', 'Smith', 'janesmith@email.com', '1985-05-15'),
  (00456789012, 'Michael', 'Johnson', 'michaeljohnson@email.com', '1992-11-23'),
  (00345678901, 'Emily', 'Davis', 'emilydavis@email.com', '1988-07-18');

INSERT INTO Customer_Account (mobileNo, pass, balance, account_type, start_date, status, points, nationalID)
VALUES
  ('12345678901', 'password123', 100.0, 'Prepaid', '2023-01-01', 'Active', 500, 0234567890),
  ('98765432101', 'password456', 250.5, 'Post paid', '2022-11-22', 'Active', 1000, 0076543210),
  ('34567890121', 'password789', 150.25, 'Prepaid', '2023-03-15', 'Active', 750, 00456789012),
  ('23456789011', 'password012', 300.75, 'Post paid', '2022-12-01', 'Active', 1200, 00345678901);
  

Set Identity_insert service_plan on;
INSERT INTO Service_Plan (planID, SMS_offered, minutes_offered, data_offered, name, price, description)
VALUES
  (1, 1000, 1000, 10, 'Basic Plan', 10, 'Basic plan with limited features'),
  (2, 2000, 2000, 20, 'Standard Plan', 20, 'Standard plan with more features'),
  (3, 3000, 3000, 30, 'Premium Plan', 30, 'Premium plan with all features'),
  (4, 500, 500, 5, 'Mini Plan', 5, 'Minimal plan for basic usage');
Set Identity_insert service_plan off;


INSERT INTO Subscription (mobileNo, planID, subscription_date, status)
VALUES
  ('12345678901', 1, '2023-01-01', 'Active'),
  ('98765432101', 2, '2022-11-22', 'Active'),
  ('34567890121', 3, '2023-04-01', 'Active'),
  ('23456789011', 4, '2023-02-15', 'Active');



Set Identity_insert plan_usage on;
INSERT INTO Plan_Usage (usageID, start_date, end_date, data_consumption, minutes_used, SMS_sent, mobileNo, planID)
VALUES
  (1, '2023-01-01', '2023-01-31', 5, 100, 50, 12345678901, 1),
  (2, '2022-11-01', '2022-11-30', 15, 200, 100, 98765432101, 2),
  (3, '2023-04-01', '2023-04-30', 25, 300, 150, 34567890121, 3),
  (4, '2023-02-15', '2023-02-28', 2, 50, 25, 23456789011, 4);
SET IDENTITY_INSERT Plan_Usage OFF;


-------------
Set Identity_insert payment on;
INSERT INTO Payment (paymentID, amount, date_of_payment, payment_method, status, mobileNo)
VALUES
  (1, 20.0, '2023-01-15', 'cash', 'Successful', '12345678901'),
  (2, 30.0, '2022-12-10', 'credit', 'Successful','98765432101'),
  (3, 40.0, '2023-05-01', 'cash', 'Successful', '34567890121'),
  (4, 10.0, '2023-03-15', 'credit', 'Successful','23456789011');
Set Identity_insert payment off;


INSERT INTO Process_Payment (paymentID, planID)
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4);


Set Identity_insert wallet on;
INSERT INTO Wallet (walletID, current_balance, currency, last_modified_date, nationalID, mobileNo)
VALUES
  (1, 100.00, 'USD', '2023-01-01', 0234567890,'12345678901'),
  (2, 200.50, 'USD', '2022-11-22', 0076543210,'98765432101'),
  (3, 150.25, 'USD', '2023-03-15', 00456789012, '34567890121'),
  (4, 300.75, 'USD', '2022-12-01', 00345678901, '23456789011');
  Set Identity_insert wallet off;


Set Identity_insert transfer_money on;
INSERT INTO Transfer_money (walletID1, walletID2, transferid, amount, transfer_date)
VALUES
  (1, 2, 1, 50.00, '2023-02-01'),
  (2, 1, 2, 25.00, '2023-03-15'),
  (3, 4, 3, 75.00, '2023-04-10'),
  (4, 3, 4, 50.00, '2023-05-05');
Set Identity_insert transfer_money off;


Set Identity_insert benefits on;
INSERT INTO Benefits (benefitID, description, validity_date, status, mobileNo)
VALUES
  (1, '10% discount on online shopping', '2023-12-31', 'Active','12345678901'),
  (2, 'Free movie ticket', '2024-06-30', 'Active','98765432101'),
  (3, '20% discount on food delivery', '2023-11-30', 'Active','34567890121'),
  (4, 'Free data bundle', '2024-01-17','Active','23456789011');
 Set Identity_insert benefits off;


Set Identity_insert Points_Group on;
INSERT INTO Points_Group(pointID, benefitID, pointsAmount, PaymentID)
VALUES
  (1, 1, 500, 1),
  (2, 2, 1000, 2),
  (3, 3, 750, 3),
  (4, 4, 100, 4);
Set Identity_insert Points_Group off;

Set Identity_insert Exclusive_Offer on;
INSERT INTO Exclusive_Offer (offerID, benefitID, internet_offered, SMS_offered, minutes_offered)
VALUES
  (1, 1, 10, 1000, 1000),
  (2, 2, 20, 2000, 2000),
  (3, 3, 15, 1500, 1500),
  (4, 4, 5, 500, 500);
  Set Identity_insert Exclusive_Offer off;


Set Identity_insert Cashback on;
INSERT INTO Cashback (CashbackID, benefitID, walletID, amount, credit_date)
VALUES
  (1, 1, 1, 10.00, '2023-01-16'),
  (2, 2, 2, 20.00, '2023-02-15'),
  (3, 3, 3, 15.00, '2023-04-10'),
  (4, 4, 4, 10.00, '2023-05-05');
  Set Identity_insert Cashback off;


INSERT INTO Plan_Provides_Benefits (benefitID, planID)
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4);


Set Identity_insert shop on;
INSERT INTO Shop (shopID, name, category)
VALUES
  (1, 'Online Store', 'Electronics'),
  (2, 'Local Grocery', 'Food'),
  (3, 'Fashion Outlet', 'Clothing'),
  (4, 'Bookstore', 'Books');
Set Identity_insert shop off;


INSERT INTO Physical_Shop (shopID, address, working_hours)
VALUES
  (2, '123 Main St', '10:00 AM - 6:00 PM'),
  (3, '456 Elm St', '11:00 AM - 7:00 PM'),
  (4, '789 Oak St', '9:00 AM - 5:00 PM');

INSERT INTO E_Shop (shopID, URL, rating)
VALUES
  (1, 'https://onlinestore.com', 4.5),
  (3, 'https://fashionoutlet.com', 4.2),
  (4, 'https://bookstore.com', 4.8);

Set Identity_insert voucher on;
INSERT INTO Voucher (voucherID, value, expiry_date, points, mobileNo, shopID, redeem_date)
VALUES
  (1, 50, '2023-12-31', 100, 12345678901, 1, '2023-02-15'),
  (2, 100, '2024-03-31', 200, 98765432101, 2, '2023-01-20'),
  (3, 75, '2023-11-30', 150, 34567890121, 3, '2023-05-10'),
  (4, 25, '2024-01-31', 50, 23456789011, 4, '2023-03-25');
Set Identity_insert voucher off;

Set Identity_insert Technical_Support_Ticket on;
INSERT INTO Technical_Support_Ticket (ticketID, mobileNo, Issue_description, priority_level, status)
VALUES
  (1, '12345678901', 'Internet connection issue', 2, 'Open'),
  (2, '98765432101', 'Device not recognizing SIM', 1, 'In Progress'),
  (3, '34567890121', 'Slow data speeds', 3, 'Resolved'),
  (4, '23456789011', 'App crashing frequently', 2, 'Resolved');
Set Identity_insert Technical_Support_Ticket off;

--Unable to show all tables at once
exec GetfirstData;
exec GETSecondDATA;

















GO
CREATE PROCEDURE GetFirstData
AS
BEGIN
  -- Select data from Customer_profile
  SELECT * FROM Customer_profile;

  -- Select data from Customer_Account
  SELECT * FROM Customer_Account;

  -- Select data from Service_Plan
  SELECT * FROM Service_Plan;

  -- Select data from Subscription
  SELECT * FROM Subscription;

  -- Select data from Plan_Usage
  SELECT * FROM Plan_Usage;

  -- Select data from Payment
  SELECT * FROM Payment;

  -- Select data from Process_Payment
  SELECT * FROM Process_Payment;

  -- Select data from Wallet
  SELECT * FROM Wallet;

  -- Select data from Transfer_money
  SELECT * FROM Transfer_money;

  -- Select data from Benefits
  SELECT * FROM Benefits;

  end;

  go
  -------------------------------------
CREATE PROCEDURE GETSecondData
AS
BEGIN
  -- Select data from PointsGroup
  SELECT * FROM Points_Group;

  -- Select data from Exclusive_Offer
  SELECT * FROM Exclusive_Offer;

  -- Select data from Cashback
  SELECT * FROM Cashback;

  -- Select data from Plan_Provides_Benefits
  SELECT * FROM Plan_Provides_Benefits;

  -- Select data from Shop
  SELECT * FROM Shop;

  -- Select data from Physical_Shop
  SELECT * FROM Physical_Shop;

  -- Select data from E-shop
  SELECT * FROM E_shop;

  -- Select data from Voucher
  SELECT * FROM Voucher;

  -- Select data from Technical_Support_Ticket
  SELECT * FROM Technical_Support_Ticket;
END;


 