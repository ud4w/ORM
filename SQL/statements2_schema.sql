CREATE TABLE "category" (
    "category_id" SERIAL PRIMARY KEY,
    "category_title" varchar,
    "category_enabled" boolean NOT NULL DEFAULT TRUE,
    "category_created" timestamp NOT NULL DEFAULT now(),
    "category_updated" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "item" (
    "item_id" SERIAL PRIMARY KEY,
    "item_name" varchar NOT NULL,
    "item_description" text,
    "item_price" decimal(5,2) NOT NULL,
    "item_popular" boolean NOT NULL DEFAULT FALSE,
    "item_created" timestamp NOT NULL DEFAULT now(),
    "item_updated" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "order" (
    "order_id" SERIAL PRIMARY KEY,
    "order_address" text,
    "order_description" text,
    "order_created" timestamp NOT NULL DEFAULT now(),
    "order_updated" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "customer" (
    "customer_id" SERIAL PRIMARY KEY,
    "customer_name" varchar,
    "customer_email" varchar,
    "customer_created" timestamp NOT NULL DEFAULT now(),
    "customer_updated" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "item__order" (
    "item_id" INTEGER NOT NULL,
    "order_id" INTEGER NOT NULL,
    "item__order_quantity" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY ("item_id", "order_id")
);


ALTER TABLE "order" ADD "customer_id" INTEGER NOT NULL,
    ADD CONSTRAINT "fk_order_customer_id" FOREIGN KEY ("customer_id")
    REFERENCES "customer" ("customer_id");

ALTER TABLE "item" ADD "category_id" INTEGER NOT NULL,
    ADD CONSTRAINT "fk_item_category_id" FOREIGN KEY ("category_id")
    REFERENCES "category" ("category_id");

ALTER TABLE "item__order" ADD CONSTRAINT "fk_itemorder_item_id" FOREIGN KEY ("item_id")
    REFERENCES "item" ("item_id");

ALTER TABLE "item__order" ADD CONSTRAINT "fk_itemorder_order_id" FOREIGN KEY ("order_id")
    REFERENCES "order" ("order_id");


CREATE OR REPLACE FUNCTION update_customer_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.customer_updated = now();
   RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER "tr_customer_updated" BEFORE UPDATE ON "customer" FOR EACH ROW EXECUTE PROCEDURE update_customer_timestamp();

CREATE OR REPLACE FUNCTION update_order_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.order_updated = now();
   RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER "tr_order_updated" BEFORE UPDATE ON "order" FOR EACH ROW EXECUTE PROCEDURE update_order_timestamp();

CREATE OR REPLACE FUNCTION update_category_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.category_updated = now();
   RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER "tr_category_updated" BEFORE UPDATE ON "category" FOR EACH ROW EXECUTE PROCEDURE update_category_timestamp();

CREATE OR REPLACE FUNCTION update_item_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.item_updated = now();
   RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER "tr_item_updated" BEFORE UPDATE ON "item" FOR EACH ROW EXECUTE PROCEDURE update_item_timestamp();

INSERT INTO "category" ("category_title") VALUES
('Tools'),
('Films'),
('Music'),
('Soft');

INSERT INTO "item" ("item_name", "category_id", "item_price") VALUES
('Screwdriver', 1, 20.0),
('Hammer', 1, 39.75),
('Nails', 1, 2.15),
('Drill', 1, 79.99),
('Axe', 1, 23.0),
('Saw', 1, 25.49),
('Perforator', 1, 89.99),
('Titanic', 2, 4.99),
('Iron Man', 2, 4.99),
('Troy', 2, 4.99),
('Dr. Jekyll and Mr. Hyde', 2, 4.99),
('Pacific Rim', 2, 4.99),
('Gayniggers from Outer Space', 2, 14.99),
('Nirvana', 3, 1.49),
('Metallica', 3, 1.99),
('Iron Maiden', 3, 2.49),
('Prodigy', 3, 2.99),
('Rammstein', 3, 1.99),
('Linkin Park', 3, 4.99),
('No Doubt', 3, 0.99),
('U2', 3, 1.99),
('Windows XP', 4, 120.0),
('Linux', 4, 0.0),
('Mac OSx', 4, 19.99),
('Winamp', 4, 14.99),
('MS Office', 4, 249.99),
('Sublime Text', 4, 59.99),
('Adobe Photoshop', 4, 130.0),
('Eset Nod32', 4, 20.0);

INSERT INTO "customer" ("customer_name", "customer_email") VALUES
('James Dunkan Davidson', 'jd.davidson@yahoo.com'),
('Lou Ashby', 'l.ashby@mail.com'),
('Hank Moody', 'h.moody@mail.com'),
('Gregory House', 'greg.house@yahoo.com'),
('Mark Travis', 'mark.travis@mail.com'),
('Hillary Clinton', 'hillary_clinton@yahoo.com'),
('John Travolta', 'j.travolta@gmail.com'),
('Samuel Johnson', 'samuel.johnson@gmail.com'),
('Chuck Norris', 'gmail@chuck_norris.com');

INSERT INTO "order" ("order_address", "order_description", "customer_id", "order_created", "order_updated") VALUES
('Guano Apes St. 17', 'Delivery after 7pm', 1, current_timestamp - interval '23 hours', current_timestamp - interval '23 hours'),
('Broadway St. 12, ap. 123', 'Cash only', 2, current_timestamp - interval '37 hours', current_timestamp - interval '37 hours'),
('Kingston Drive, 145', 'Beware of angry birds', 5, current_timestamp - interval '34 minutes ', current_timestamp - interval '34 minutes '),
('Bush Ave, 45', 'Call me first.', 7, current_timestamp - interval '28 hours', current_timestamp - interval '28 hours'),
('Monroe St., 2', 'It is an office building, so you will need some id', 6, current_timestamp - interval '15 minutes', current_timestamp - interval '15 minutes'),
('Mullholland Drive, 12', 'I will be in a red dress', 9, current_timestamp - interval '5 minutes', current_timestamp - interval '5 minutes'),
('J. Bush St., 22', 'Take some naked photos too.', 3, current_timestamp - interval '1 minute', current_timestamp - interval '1 minute');

INSERT INTO "item__order" ("item_id", "order_id", "item__order_quantity") VALUES
(1, 1, 3),
(2, 1, 1),
(5, 1, 2),
(12, 1, 1),
(16, 1, 3),
(3, 2, 1),
(6, 2, 1),
(7, 2, 4),
(4, 3, 3),
(11, 3, 1),
(9, 3, 1),
(12, 4, 2),
(16, 4, 1),
(18, 4, 2),
(1, 5, 2),
(7, 6, 3),
(8, 6, 2);
