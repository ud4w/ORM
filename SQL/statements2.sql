SELECT item_name, category_id  FROM "item";

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    WHERE order_id=?;

SELECT order_id
    FROM "order"
    INNER JOIN "item__order" USING(order_id)
    WHERE item_id=?;

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
    WHERE order_created > now() - interval '1 hour';

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
    WHERE order_created > current_date;

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
    WHERE order_created > current_date - interval '1 day';

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
WHERE order_created > now() - interval '1 hour' AND item.category_id = ?;

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
    WHERE order_created > current_date AND item.category_id = ?;

SELECT item_name
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER JOIN "order" USING(order_id)
    WHERE order_created > current_date - interval '1 day' AND item.category_id = ?;

SELECT item_name
    FROM "item"
    WHERE item_name LIKE '?%';

SELECT item_name
    FROM "item"
    WHERE item_name LIKE '%?';

SELECT item_name
    FROM "item"
    WHERE item_name LIKE '%?%';

SELECT category_title,
    (SELECT count(item_id)
        FROM "item"
        WHERE item.category_id = category.category_id
    )
    FROM "category";

SELECT order_id, count(item_id)
    FROM "item__order"
    GROUP BY order_id
    ORDER BY order_id ASC;

SELECT item_id, count(order_id)
    FROM "item__order"
    GROUP BY item_id
    ORDER BY item_id ASC;

SELECT order_id, sum(item__order_quantity * item_price)
    FROM "order"
    INNER JOIN "item__order" USING(order_id)
    INNER jOIN "item" USING(item_id)
    GROUP BY order_id
    ORDER BY order_created;

SELECT item_name, item_price, item__order_quantity, item_price * item__order_quantity AS sum
    FROM "item"
    INNER JOIN "item__order" USING(item_id)
    INNER jOIN "order" USING(order_id)
    WHERE order_id = ?
    GROUP BY item_name, item_price, item__order_quantity;

SELECT category_title, count(item_name), sum(item_price * item__order_quantity)
    FROM "category"
    INNER jOIN "item" USING(category_id)
    INNER jOIN "item__order" USING(item_id)
    WHERE order_id = ?
    GROUP BY category_title;

SELECT customer_name
    FROM "customer"
    INNER jOIN "order" USING(customer_id)
    INNER jOIN "item__order" USING(order_id)
    INNER JOIN "item" USING(item_id)
    INNER jOIN "category" USING(category_id)
    WHERE category_id = ? AND order_created > current_date - interval '1 day'
    GROUP BY customer_name
    ORDER BY customer_name;

SELECT customer_name
    FROM "customer"
    INNER jOIN "order" USING(customer_id)
    INNER jOIN "item__order" USING(order_id)
    INNER JOIN "item" USING(item_id)
    INNER jOIN "category" USING(category_id)
    WHERE order_created > now() - interval '24 hour'
    GROUP BY customer_name
    ORDER BY customer_name;

SELECT customer_name
    FROM "customer"
    INNER jOIN "order" USING(customer_id)
    INNER jOIN "item__order" USING(order_id)
    INNER JOIN "item" USING(item_id)
    INNER jOIN "category" USING(category_id)
    WHERE item_id = ?
    GROUP BY customer_name
    ORDER BY customer_name;

SELECT (
            CASE 
                WHEN category_enabled = TRUE
                    THEN format('http://img.domain.com/category/%s.jpg', category_id)
                ELSE format('http://img.domain.com/category/%s_disabled.jpg', category_id)
            END
            ) AS category_image
    FROM "category";

UPDATE "item"
    SET item_popular = p.popular
    FROM (
        SELECT item_id, (CASE
                        WHEN sum(item__order_quantity) > 2
                            THEN TRUE
                        ELSE FALSE
                    END) AS popular
        FROM "item__order"
        GROUP BY item_id
    ) p
    WHERE item.item_id = p.item_id;

UPDATE "category"
    SET category_enabled = (
        CASE
            WHEN category_id = ?
                THEN TRUE
            WHEN category_id = ?
                THEN TRUE
            ELSE FALSE
        END
    );
