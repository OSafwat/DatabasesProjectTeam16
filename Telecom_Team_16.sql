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
		CONSTRAINT Points_Group_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID) ON DELETE CASCADE,
		CONSTRAINT Points_Group_paymentID_FK FOREIGN KEY (paymentID) REFERENCES Payment(paymentID)
	);

	CREATE TABLE Exclusive_Offer (
		offerID INT IDENTITY(1,1),
		benefitID INT,
		internet_offered INT,
		SMS_offered INT,
		minutes_offered INT,
		PRIMARY KEY (offerID, benefitID),
		CONSTRAINT Exclusive_Offer_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID) ON DELETE CASCADE
	);

	CREATE TABLE Cashback (
		cashbackID INT IDENTITY(1,1),
		benefitID INT,
		walletID INT,
		amount INT,
		credit_date DATE,
		PRIMARY KEY (cashbackID, benefitID),
		CONSTRAINT Cashback_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID) ON DELETE CASCADE,
		CONSTRAINT Cashback_walletID_FK FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
	);

	CREATE TABLE Plan_Provides_Benefits (
		benefitID INT,
		planID INT,
		PRIMARY KEY (benefitID, planID),
		CONSTRAINT Plan_Provides_Benefits_benefitID_FK FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID) ON DELETE CASCADE,
		CONSTRAINT Plan_Provides_Benefits_planID_FK FOREIGN KEY (planID) REFERENCES Service_Plan(planID) ON DELETE CASCADE
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

-- helper function
CREATE FUNCTION calculate_extra_amount (@paymentID INT, @planID INT)
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

-- helper function
CREATE FUNCTION calculate_remaining_balance (@paymentID INT, @planID INT)
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
	DROP FUNCTION Subscribed_plans_5_Months;
	DROP PROCEDURE Initiate_balance_payment;
	DROP PROCEDURE Initiate_plan_payment;
	DROP PROCEDURE Payment_wallet_cashback;
	DROP PROCEDURE Redeem_voucher_points;
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
--------------------------------------------------------------------------------------------------------------

-- 2.2a
CREATE VIEW allCustomerAccounts AS
SELECT P.*, A.mobileNo, A.balance, A.account_type, A.start_date, A.points
FROM Customer_Profile P 
INNER JOIN Customer_Account A ON P.nationalID = A.nationalID
WHERE A.status = 'active'; 

GO

-- 2.2b
CREATE VIEW allServicePlans AS
SELECT * 
FROM Service_Plan;

GO


-- 2.2c
CREATE VIEW allBenefits AS
SELECT * From Benefits B 
WHERE B.status = 'active';

Go

-- 2.2d
CREATE VIEW accountPayments AS
SELECT P.*, A.balance, A.account_type, A.start_date, A.status AS account_status, A.points
FROM Payment P 
INNER JOIN Customer_Account A ON P.mobileNo = A.mobileNo;

GO

SELECT * FROM accountPayments

GO

-- 2.2e
CREATE VIEW allShops AS
SELECT *
FROM Shop;

GO

-- 2.2f
CREATE VIEW allResolvedTickets AS
SELECT * FROM Technical_Support_Ticket
WHERE status = 'Resolved';

GO

SELECT * FROM allResolvedTickets

GO


-- 2.2g
CREATE VIEW CustomerWallet AS
SELECT W.walletID, W.current_balance, W.currency, W.last_modified_date, C.first_name, C.last_name
FROM Wallet W
INNER JOIN Customer_Profile C ON W.nationalID = C.nationalID;

GO

SELECT * FROM CustomerWallet
SELECT * FROM Customer_Profile
SELECT * FROM Wallet

GO

-- 2.2h
CREATE VIEW E_shopVouchers AS
SELECT E.*, V.voucherId, V.value
FROM E_Shop E
INNER JOIN Voucher V ON E.shopId = V.shopId
WHERE V.redeem_date IS NOT NULL;
		
GO

SELECT * FROM E_shopVouchers
SELECT * FROM E_Shop
SELECT * FROM Voucher

GO

-- 2.2i
CREATE VIEW PhysicalStoreVouchers AS
SELECT P.*, V.voucherId, V.value
FROM Physical_Shop P
INNER JOIN Voucher V ON P.shopID = V.shopID
WHERE V.redeem_date IS NOT NULL;

GO

SELECT * FROM Physical_Shop
SELECT * FROM Voucher
SELECT * FROM PhysicalStoreVouchers

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
	SELECT c.mobileNo, c.balance, c.account_type, c.status, su.planID, sp.name AS plan_name
	FROM Customer_Account c
	INNER JOIN Subscription su ON c.mobileNo = su.mobileNo
	INNER JOIN Service_Plan sp ON su.planID = sp.planID -- Required to show plan name.
END

GO

EXEC Account_Plan
SELECT * FROM Customer_Account
SELECT * FROM Service_Plan

GO

-- 2.3b
CREATE FUNCTION Account_Plan_Date (@Subscription_Date DATE, @Plan_id INT)
RETURNS TABLE
AS
RETURN (
	SELECT CA.mobileNo, CA.balance, CA.account_type, CA.start_date, CA.status, CA.points
	FROM Customer_Account CA
	INNER JOIN Subscription S ON S.mobileNo = CA.mobileNo
	WHERE @Plan_id = S.planID AND @Subscription_Date = S.subscription_date
)


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

	SET @TotalPoints = ISNULL(@TotalPoints, 0)

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
	RETURN ISNULL(@CashbackReturned, 0)
END


GO

SELECT * FROM Plan_Provides_Benefits
SELECT * FROM Wallet
SELECT * FROM Cashback

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
	RETURN ISNULL(@Transaction_Average, 0)
END
GO

SELECT * FROM Transfer_Money
SELECT * FROM Wallet
PRINT dbo.Wallet_Transfer_Amount(1, '2022-02-1', '2024-02-1')

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
	SELECT 1 
	FROM Subscription S
	WHERE S.planID = SP.planID AND @MobileNo = mobileNo
)

GO

-- 2.4d
CREATE FUNCTION Usage_Plan_CurrentMonth
(@MobileNo CHAR(11))
RETURNS TABLE
AS
RETURN (
	SELECT S.planID, PU.data_consumption, PU.minutes_used, PU.SMS_sent
	FROM Plan_Usage PU
	INNER JOIN Subscription S ON S.planID = PU.planID
	WHERE @MobileNo = PU.mobileNo AND S.status = 'active' AND (MONTH(GETDATE()) = MONTH(PU.start_date) OR MONTH(GETDATE()) = MONTH(PU.end_date))
)

GO

-- 2.4e
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
-- Which payment? I'll assume it wants the remaining amount on the *most recent* payment the user
-- made to the given plan. Since paymentID is IDENTITY(1, 1), the payment with the maximum ID
-- is the most recent one.
CREATE FUNCTION Remaining_plan_amount (@MobileNo char(11), @plan_name varchar(50))
RETURNS INT
AS
BEGIN
	DECLARE @remaining_amount INT

	SELECT TOP 1 @remaining_amount = PP.remaining_balance
	FROM Service_Plan SP 
	INNER JOIN Process_Payment PP ON SP.planID = PP.planID
	INNER JOIN Payment P ON PP.paymentID = P.paymentID
	WHERE P.mobileNo = @MobileNo AND SP.name = @plan_name
	ORDER BY PP.paymentID DESC

	RETURN ISNULL(@remaining_amount, 0)
END;

GO

-- 2.4i
CREATE FUNCTION Extra_plan_amount (@MobileNo char(11), @plan_name varchar(50))
RETURNS INT
AS
BEGIN
	DECLARE @extra_amount INT

	SELECT TOP 1 @extra_amount = PP.extra_amount
	FROM Service_Plan SP 
	INNER JOIN Process_Payment PP ON SP.planID = PP.planID
	INNER JOIN Payment P ON PP.paymentID = P.paymentID
	WHERE P.mobileNo = @MobileNo AND SP.name = @plan_name
	ORDER BY PP.paymentID DESC

	RETURN ISNULL(@extra_amount, 0)
END;

GO

-- 2.4j
CREATE PROCEDURE Top_Successful_Payments (@MobileNo char(11))
AS
	SELECT TOP 10 p.paymentID, p.amount, p.date_of_payment
	FROM Payment p
	WHERE p.mobileNo = @MobileNo
	ORDER BY p.amount DESC;

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
	SELECT @payment_id = MAX(paymentID) FROM Payment -- paymentID is IDENTITY(1, 1) so the last payment added will have highest ID

	INSERT INTO Process_Payment VALUES (@payment_id, @plan_id)
	
	DECLARE @remaining_balance DECIMAL(10, 1)
	SELECT @remaining_balance = remaining_balance FROM Process_Payment WHERE paymentID = @payment_id

	-- what if they have extra amounts or remaining balances accumulated from previous payments? not sure how to handle
	DECLARE @new_status VARCHAR(50)
	IF @remaining_balance = 0
	BEGIN
		SET @new_status = 'active'
	END
	ELSE
	BEGIN
		SET @new_status = 'onhold'
	END
	UPDATE Subscription
	SET status = @new_status
	WHERE planID = @plan_id AND mobileNo = @MobileNo
END

GO
-- 2.4m
CREATE PROCEDURE Payment_wallet_cashback
@MobileNo CHAR(11),
@payment_id INT,
@benefit_id INT
AS
BEGIN
	DECLARE @cashback_amount DECIMAL(10, 2)
	SELECT @cashback_amount = 0.1 * amount
	FROM Payment
	WHERE payment_id = @payment_id
	
	-- if wallet doesn't exist, @wallet_id will be set to null
	DECLARE @wallet_id INT
	SELECT @wallet_id = W.walletID 
	FROM Wallet W
	INNER JOIN Customer_Account CA ON W.nationalID = CA.nationalID
	WHERE CA.mobileNo = @MobileNo

	INSERT INTO Cashback VALUES (@benefit_id, @wallet_id, @cashback_amount, GETDATE())

	UPDATE Wallet
	SET current_balance = current_balance + @cashback_amount, last_modified_date = GETDATE()
	WHERE walletID = @wallet_id
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

GO
