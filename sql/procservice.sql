CREATE PROCEDURE "DBA"."WeekMenu"()
RESULT (itemID varchar(5), itemName text, itemCourse text, itemPrice integer)
BEGIN
    select *
    from caterItems
END

CREATE SERVICE 'weekmenu' TYPE JSON AUTHORIZATION OFF USER "DBA" URL ON METHODS 'GET' AS CALL WeekMenu();

CREATE PROCEDURE "DBA"."SetMenu"(in orderID varchar(5), in orderName text, in orderPrice integer)
RESULT (status int)
BEGIN
    DECLARE @status int;
    INSERT INTO caterMenu(menuID, menuItem, menuItemPrice) values
    (in_orderID, in_orderName, in_orderPrice);
    IF EXISTS (SELECT menuID FROM caterMenu WHERE menuID = in_orderID)
        THEN SET @status = 200;
    ELSE BEGIN
        SET @status = 501;
        END
    ENDIF;
END

CREATE SERVICE 'setweek' TYPE JSON AUTHORIZATION OFF USER "DBA" URL ON METHODS 'GET' AS CALL SetMenu(:orderID, :orderName, :orderPrice);

CREATE PROCEDURE "DBA"."ClearMenu"()
RESULT ("status" int)
BEGIN
    DECLARE @status int;
    DELETE FROM caterMenu;
    IF EXISTS (SELECT * FROM caterMenu)
        THEN SET @status = 501;
    ELSE BEGIN
        SET @status = 200;
        END
    ENDIF;
    SELECT @status;
END;

CREATE SERVICE 'clearmenu' TYPE JSON AUTHORIZATION OFF USER "DBA" URL ON METHODS 'GET' AS CALL ClearMenu();

CREATE PROCEDURE "DBA"."parseData"(in data text)
RESULT (status int)
BEGIN
     DECLARE json_data text;
     SET json_data = in_data;
     CALL sp_parse_json ( 'sql_array', json_data);
     SELECT sql_array [[row_num]] .orderID, sql_array [[row_num]] .orderName, sql_array [[row_num]] .orderPrice FROM sa_rowgenerate (1, 10);
    IF EXISTS (SELECT * FROM caterMenu)
            THEN SET @status = 200;
        ELSE BEGIN
            SET @status = 501;
            END
        ENDIF;
END;