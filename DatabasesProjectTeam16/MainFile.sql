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
