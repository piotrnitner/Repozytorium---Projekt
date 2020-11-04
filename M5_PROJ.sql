--utworzenie roli expense_tracker_user oraz odebranie prawa do tworzenia do PUBLIC
DROP ROLE IF EXISTS expense_tracker_user;
CREATE ROLE expense_tracker_user WITH LOGIN PASSWORD 'CEBE0B3C0d!';
REVOKE CREATE ON SCHEMA public FROM expense_tracker_user;

--usuniêcie roli expense_tracker
DROP SCHEMA IF EXISTS expense_tracker CASCADE;

--utworzenie nowej roli expense_tracker_group
DROP ROLE IF EXISTS expense_tracker_group;
CREATE ROLE expense_tracker_group;

--utworzenie schematu expense_tracker (domyslny wlasciciel expense_tracker_group)
DROP SCHEMA IF EXISTS expense_tracker;
CREATE SCHEMA expense_tracker AUTHORIZATION expense_tracker_group;
GRANT ALL PRIVILEGES ON SCHEMA expense_tracker TO expense_tracker_group;

--przydzielenie roli expense_tracker_group do uzytkownika expense_tracker_user
GRANT expense_tracker_group TO expense_tracker_user;

--ponowne utworzenie tabel w docelowej konfiguracji

--utworzenie tabeli bank_account_owner + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.bank_account_owner;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_owner
	(id_ba_own SERIAL
	,owner_name VARCHAR(50) NOT NULL
	,user_login INTEGER NOT NULL
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,is_common_account BOOLEAN DEFAULT FALSE NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_bank_account_owner PRIMARY KEY (id_ba_own)
	);

--utworzenie tabeli bank_account_types + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk + klucz obcy
DROP TABLE IF EXISTS expense_tracker.bank_account_types;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_types
	(id_ba_type SERIAL
	,ba_type VARCHAR(50) NOT NULL
	,ba_desc VARCHAR (250)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,is_common_account BOOLEAN DEFAULT FALSE NOT NULL
	,id_ba_own INTEGER 
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_id_ba_type PRIMARY KEY (id_ba_type)
	,CONSTRAINT fk_id_ba_own FOREIGN KEY (id_ba_own) REFERENCES expense_tracker.bank_account_owner(id_ba_own)
	);

--utworzenie tabeli transaction_bank_accounts + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transaction_bank_accounts;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_bank_accounts
	 (id_trans_ba SERIAL
	 ,id_ba_own INTEGER
	 ,id_ba_typ INTEGER
	 ,bank_account_name VARCHAR(50) NOT NULL
	 ,bank_account_desc VARCHAR(250)
	 ,active BOOLEAN DEFAULT TRUE NOT NULL
	 ,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	 ,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	 ,CONSTRAINT pk_id_trans_ba PRIMARY KEY (id_trans_ba)
	 ,CONSTRAINT fk_bank_account_owner FOREIGN KEY (id_ba_own) REFERENCES expense_tracker.bank_account_owner(id_ba_own)
	 ,CONSTRAINT fk_bank_account_types FOREIGN KEY (id_ba_typ) REFERENCES expense_tracker.bank_account_types(id_ba_type)
	 );

--utworzenie tabeli transaction_category + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transaction_category;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_category
	(id_trans_cat SERIAL
	,category_name VARCHAR(50) NOT NULL
	,category_description VARCHAR (250)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_transaction_category PRIMARY KEY (id_trans_cat)
	);

--utworzenie tabeli transaction_subcategory + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transaction_subcategory;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_subcategory
	(id_trans_subcat SERIAL
	,id_trans_cat INTEGER
	,subcategory_name VARCHAR(50) NOT NULL
	,subcategory_description VARCHAR (250)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_transaction_subcategory PRIMARY KEY (id_trans_subcat)
	,CONSTRAINT fk_id_trans_cat FOREIGN KEY (id_trans_cat) REFERENCES expense_tracker.transaction_category(id_trans_cat)
	);

--utworzenie tabeli bank_account_types + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.bank_account_types;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_types
	(id_ba_typ SERIAL
	,ba_type VARCHAR(50) NOT NULL
	,ba_desc VARCHAR (250)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,is_common_account BOOLEAN DEFAULT FALSE NOT NULL
	,id_ba_own INTEGER
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_bank_account_types PRIMARY KEY (id_ba_typ)
	);

--utworzenie tabeli users + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.users;
CREATE TABLE IF NOT EXISTS expense_tracker.users
	(id_user SERIAL NOT NULL
	,user_login VARCHAR(25) NOT NULL
	,user_name VARCHAR(50) NOT NULL
	,user_password VARCHAR(100) NOT NULL
	,password_salt VARCHAR(50) NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_users PRIMARY KEY (id_user)
	);

--utworzenie tabeli transaction_category + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transaction_category;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_category
	(id_trans_cat SERIAL
	,category_name VARCHAR(50) NOT NULL
	,category_description VARCHAR (250)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_transaction_category PRIMARY KEY (id_trans_cat)
	);

--utworzenie tabeli transaction_type + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transaction_type;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_type
	(id_trans_type SERIAL
	,transaction_type_name VARCHAR (25)
	,transaction_type_desc VARCHAR (100)
	,active BOOLEAN DEFAULT FALSE NOT NULL
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_transaction_type PRIMARY KEY (id_trans_type)
	);

--utworzenie tabeli transactions + dodanie sk³adni IF NOT EXISTS + sk³adnia CONSTRAINT +pk
DROP TABLE IF EXISTS expense_tracker.transactions;
CREATE TABLE IF NOT EXISTS expense_tracker.transactions
	(id_transaction SERIAL
	,id_trans_ba INTEGER
	,id_trans_cat INTEGER
	,id_trans_subcat INTEGER
	,id_trans_type INTEGER
	,id_user INTEGER
	,transaction_date DATE DEFAULT CURRENT_DATE
	,transaction_value NUMERIC (9,2)
	,transaction_description TEXT
	,insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	,CONSTRAINT pk_transactions PRIMARY KEY (id_transaction)
	,CONSTRAINT transaction_bank_accounts_fk FOREIGN KEY (id_trans_ba) REFERENCES expense_tracker.transaction_bank_accounts (id_trans_ba)
	,CONSTRAINT transaction_category_fk FOREIGN KEY (id_trans_cat) REFERENCES expense_tracker.transaction_category(id_trans_cat)
	,CONSTRAINT transaction_subcategory_fk FOREIGN KEY (id_trans_subcat) REFERENCES expense_tracker.transaction_subcategory(id_trans_subcat)
	,CONSTRAINT transaction_type_fk FOREIGN KEY (id_trans_type) REFERENCES expense_tracker.transaction_type(id_trans_type)
	,CONSTRAINT users_fk FOREIGN KEY (id_user) REFERENCES expense_tracker.users(id_user)
	);

--weryfikacja na diagramie ERD, powi¹zania prawid³owe

SELECT * FROM expense_tracker.transactions;

--dodanie rekordu do expense_tracker.bank_account_owner
INSERT INTO expense_tracker.bank_account_owner 
	(owner_name
	, user_login
	, active
	, is_common_account)
	VALUES 
	('Piotr'
	,'01'
	,'1'
	,'1'
	);
--SELECT * FROM expense_tracker.bank_account_owner;

--dodanie rekordu do expense_tracker.bank_account_types
INSERT INTO expense_tracker.bank_account_types
	(ba_type
	,ba_desc 
	,active 
	,is_common_account
	,id_ba_own)
	VALUES 
	('Main account'
	,'Konto podstawowe do codziennych wydatków'
	,'1'
	,'1'
	,'0001'
	);
--SELECT * FROM expense_tracker.bank_account_types;

--dodanie rekordu do expense_tracker.transaction_bank_accounts
INSERT INTO expense_tracker.transaction_bank_accounts 
	(id_ba_own
	,id_ba_typ
	,bank_account_name
	,bank_account_desc 
	,active)
	VALUES
	(1
	,1
	,'MIL'
	,'Bank Millennium'
	,'1'
	);
--SELECT * FROM expense_tracker.transaction_bank_accounts;
	
--dodanie rekordu do expense_tracker.transaction_category
INSERT INTO expense_tracker.transaction_category
	(category_name
	,category_description 
	,active)
	VALUES
	('op³aty Spó³dzielnia Mieszkaniowa'
	,'czynsz i op³aty sta³e wg rozliczenia na eBOK'
	,'1');
--SELECT * FROM expense_tracker.transaction_category;

--dodanie rekordu do expense_tracker.transaction_subcategory
INSERT INTO expense_tracker.transaction_subcategory
	(id_trans_cat 
	,subcategory_name 
	,subcategory_description 
	,active)
	VALUES
	(1
	,'mieszkanie'
	,'czynsz za mieszkanie - podstawowy'
	,'1'
	);
--SELECT * FROM expense_tracker.transaction_subcategory;

--dodanie rekordu do expense_tracker.transaction_type
INSERT INTO expense_tracker.transaction_type
	(transaction_type_name
	,transaction_type_desc 
	,active)
	VALUES
	('przelew'
	,'standardowy przelew internetowy'
	,'1'
	);
--SELECT * FROM expense_tracker.transaction_type;

--dodanie rekordu do expense_tracker.transactions
INSERT INTO expense_tracker.transactions
	(id_trans_ba
	,id_trans_cat
	,id_trans_subcat
	,id_trans_type
	,transaction_value
	,transaction_description)
	VALUES
	(1
	,1
	,1
	,1
	,500
	,'rachunki - SM'
	);
SELECT * FROM expense_tracker.transactions;

--dodanie rekordu do expense_tracker.users
INSERT INTO expense_tracker.users
	(user_login
	,user_name 
	,user_password 
	,password_salt)
	VALUES
	('pnitner'
	,'Piotr Nitner'
	,'AlaMaKota123!'
	,'nie mam pomys³u co to password salt :)'
	);
--SELECT * FROM expense_tracker.users;

--utworzenie backup
--pg_dump --host localhost ^
        --port 5432 ^
        --username postgres ^
        --format plain ^
	--clean ^
        --file "c:\PostgreSQL_dump\expense_tracker" ^
        --postgres


--przywrocenie z kopii zapasowej
--psql -U postgres -p 5432 -h localhost -d postgres -f "c:\PostgreSQL_dump\expense_tracker"












