CREATE DATABASE shop;
CREATE USER shop WITH password '123456';
CREATE USER viewer WITH password '234567';
GRANT ALL privileges ON DATABASE shop TO shop;
CREATE SCHEMA shop_schema;
GRANT CONNECT ON DATABASE shop TO viewer;
GRANT USAGE ON SCHEMA shop_schema TO viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA shop_schema TO viewer;
ALTER DEFAULT PRIVILEGES IN SCHEMA shop_schema GRANT SELECT ON TABLES TO viewer;
\connect shop
CREATE TABLE IF NOT EXISTS categories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName CHAR(255)
);
INSERT INTO Categories (CategoryName) VALUES('Trusilia');
INSERT INTO Categories (CategoryName) VALUES('Pigamas');
INSERT INTO Categories (CategoryName) VALUES('Tapki');

CREATE TABLE Items (
    ItemID SERIAL PRIMARY KEY,
    ItemName CHAR (255),
    CategoryID INT NOT NULL REFERENCES Categories(CategoryID),
    ItemPrice NUMERIC(16, 2)
);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Simeiki', 1, 1);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Pantaloni', 1, 1);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Devkam', 1, 1);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('forKids', 2, 2);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Muzjikam', 2, 3);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Babam', 2, 3);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Detiam', 3, 5);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Men', 3, 7);
INSERT INTO Items (ItemName, CategoryID, ItemPrice) VALUES('Women', 3, 8);

UPDATE Items SET ItemPrice = 3.50 WHERE ItemID = 1;
UPDATE Items SET ItemPrice = ItemPrice * 1.1;
SELECT * FROM Items ORDER BY ItemID;

SELECT * FROM Items ORDER BY ItemName;
SELECT * FROM Items ORDER BY ItemPrice DESC;
SELECT * FROM Items ORDER BY ItemPrice DESC LIMIT 3;
SELECT * FROM Items ORDER BY ItemPrice LIMIT 3;
SELECT * FROM Items ORDER BY ItemPrice DESC LIMIT 3 OFFSET 3;
SELECT ItemName FROM Items WHERE ItemPrice=(SELECT MAX(ItemPrice) FROM Items);
SELECT ItemName FROM Items WHERE ItemPrice=(SELECT MIN(ItemPrice) FROM Items);
SELECT COUNT(CategoryID) FROM Items;
SELECT AVG(ItemPrice) FROM Items;

CREATE VIEW List AS
SELECT * FROM Items ORDER BY ItemPrice DESC LIMIT 3;

SELECT * FROM List;
