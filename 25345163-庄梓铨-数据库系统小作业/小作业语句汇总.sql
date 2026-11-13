-- TPC-H 数据库综合实验；MySQL 8.0.46。

-- 数据库
CREATE DATABASE IF NOT EXISTS TPCH CHARACTER SET utf8mb4;
USE TPCH;

-- 基础表与关联表
CREATE TABLE Region (
    regionkey INT NOT NULL,
    name CHAR(25),
    comment VARCHAR(152),
    CONSTRAINT PK_Region PRIMARY KEY (regionkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Nation (
    nationkey INT NOT NULL,
    name CHAR(25),
    regionkey INT,
    comment VARCHAR(152),
    CONSTRAINT PK_Nation PRIMARY KEY (nationkey),
    CONSTRAINT FK_Nation_Region FOREIGN KEY (regionkey)
        REFERENCES Region (regionkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Supplier (
    suppkey INT NOT NULL,
    name CHAR(25),
    address VARCHAR(40),
    nationkey INT,
    phone CHAR(15),
    acctbal DECIMAL(10,2),
    comment VARCHAR(101),
    CONSTRAINT PK_Supplier PRIMARY KEY (suppkey),
    CONSTRAINT FK_Supplier_Nation FOREIGN KEY (nationkey)
        REFERENCES Nation (nationkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Part (
    partkey INT NOT NULL,
    name VARCHAR(55),
    mfgr CHAR(25),
    brand CHAR(10),
    type VARCHAR(25),
    size INT,
    container CHAR(10),
    retailprice DECIMAL(10,2),
    comment VARCHAR(23),
    CONSTRAINT PK_Part PRIMARY KEY (partkey),
    CONSTRAINT CK_Part_Price CHECK (retailprice > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PartSupp (
    partkey INT NOT NULL,
    suppkey INT NOT NULL,
    availqty INT,
    supplycost DECIMAL(10,2),
    comment VARCHAR(199),
    CONSTRAINT PK_PartSupp PRIMARY KEY (partkey, suppkey),
    CONSTRAINT FK_PartSupp_Part FOREIGN KEY (partkey)
        REFERENCES Part (partkey),
    CONSTRAINT FK_PartSupp_Supplier FOREIGN KEY (suppkey)
        REFERENCES Supplier (suppkey),
    CONSTRAINT CK_PartSupp_AvailQty CHECK (availqty >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Customer (
    custkey INT NOT NULL,
    name VARCHAR(25),
    address VARCHAR(40),
    nationkey INT,
    phone CHAR(15),
    acctbal DECIMAL(10,2),
    mktsegment CHAR(10),
    comment VARCHAR(117),
    CONSTRAINT PK_Customer PRIMARY KEY (custkey),
    CONSTRAINT FK_Customer_Nation FOREIGN KEY (nationkey)
        REFERENCES Nation (nationkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Orders (
    orderkey INT NOT NULL,
    custkey INT,
    orderstatus CHAR(1),
    totalprice DECIMAL(10,2),
    orderdate DATE,
    orderpriority CHAR(15),
    clerk CHAR(15),
    shippriority INT,
    comment VARCHAR(79),
    CONSTRAINT PK_Orders PRIMARY KEY (orderkey),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (custkey)
        REFERENCES Customer (custkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Lineitem (
    orderkey INT NOT NULL,
    partkey INT NOT NULL,
    suppkey INT NOT NULL,
    linenumber INT NOT NULL,
    quantity DECIMAL(10,2),
    extendedprice DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    returnflag CHAR(1),
    linestatus CHAR(1),
    shipdate DATE,
    commitdate DATE,
    receiptdate DATE,
    shipinstruct CHAR(25),
    shipmode CHAR(10),
    comment VARCHAR(44),
    CONSTRAINT PK_Lineitem PRIMARY KEY (orderkey, linenumber),
    CONSTRAINT FK_Lineitem_Orders FOREIGN KEY (orderkey)
        REFERENCES Orders (orderkey),
    CONSTRAINT FK_Lineitem_PartSupp FOREIGN KEY (partkey, suppkey)
        REFERENCES PartSupp (partkey, suppkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 测试数据
INSERT INTO Region (regionkey, name, comment) VALUES
(1, '亚洲', '测试地区'),
(2, '欧洲', '测试地区'),
(3, '美洲', '测试地区');

INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES
(10, '中国', 1, '测试国家'),
(11, '日本', 1, '测试国家'),
(20, '德国', 2, '测试国家'),
(30, '美国', 3, '测试国家');

INSERT INTO Supplier (suppkey, name, address, nationkey, phone, acctbal, comment) VALUES
(101, '供应商甲', '上海市', 10, '021-00000001', 1200.00, '测试供应商'),
(102, '供应商乙', '北京市', 10, '010-00000002', 800.00, '测试供应商'),
(103, '供应商丙', '东京市', 11, '03-00000003', 500.00, '测试供应商'),
(104, '供应商丁', '柏林市', 20, '030-00000004', 300.00, '测试供应商');

INSERT INTO Part (partkey, name, mfgr, brand, type, size, container, retailprice, comment) VALUES
(201, '螺栓', '制造商甲', '品牌甲', '五金', 3, '盒', 12.50, '测试零件'),
(202, '螺母', '制造商乙', '品牌乙', '五金', 2, '袋', 8.20, '测试零件'),
(203, '齿轮', '制造商丙', '品牌丙', '机械', 5, '箱', 45.00, '测试零件'),
(204, '轴承', '制造商丁', '品牌丁', '机械', 4, '箱', 30.00, '测试零件');

INSERT INTO PartSupp (partkey, suppkey, availqty, supplycost, comment) VALUES
(201, 101, 600, 5.00, '高库存'),
(201, 102, 50, 5.20, '触发器测试：50 降至 5'),
(202, 102, 15, 2.00, '触发器测试：15 降至 12'),
(202, 103, 8, 2.10, '初始低库存'),
(203, 104, 400, 20.00, '正常库存');

INSERT INTO Customer (custkey, name, address, nationkey, phone, acctbal, mktsegment, comment) VALUES
(301, '顾客甲', '上海市', 10, '021-10000001', 1000.00, '零售', '有多笔订单'),
(302, '顾客乙', '北京市', 10, '010-10000002', 2000.00, '企业', '同国高余额'),
(303, '顾客丙', '东京市', 11, '03-10000003', 700.00, '零售', '无订单'),
(304, '顾客丁', '柏林市', 20, '030-10000004', 900.00, '企业', '测试顾客');

INSERT INTO Orders (orderkey, custkey, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment) VALUES
(401, 301, 'O', 100.00, '2026-01-10', '3-MEDIUM', 'Clerk#000000001', 0, '顾客甲订单一'),
(402, 301, 'O', 60.00, '2026-02-11', '2-HIGH', 'Clerk#000000002', 0, '顾客甲订单二'),
(403, 302, 'F', 90.00, '2026-03-12', '3-MEDIUM', 'Clerk#000000003', 0, '顾客乙订单'),
(404, 304, 'O', 120.00, '2026-04-13', '1-URGENT', 'Clerk#000000004', 0, '顾客丁订单');

INSERT INTO Lineitem (orderkey, partkey, suppkey, linenumber, quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment) VALUES
(401, 201, 101, 1, 2.00, 25.00, 0.00, 0.05, 'N', 'O', '2026-01-15', '2026-01-14', '2026-01-17', '交给收货人', '公路', '测试明细'),
(402, 201, 102, 1, 1.00, 12.50, 0.00, 0.05, 'N', 'O', '2026-02-16', '2026-02-15', '2026-02-18', '交给收货人', '铁路', '测试明细'),
(403, 202, 103, 1, 4.00, 32.80, 0.05, 0.00, 'N', 'F', '2026-03-17', '2026-03-16', '2026-03-19', '交给收货人', '航空', '测试明细'),
(404, 203, 104, 1, 3.00, 135.00, 0.00, 0.08, 'N', 'O', '2026-04-18', '2026-04-17', '2026-04-20', '交给收货人', '公路', '测试明细');

SELECT 'Region' AS table_name, COUNT(*) AS row_count FROM Region
UNION ALL SELECT 'Nation', COUNT(*) FROM Nation
UNION ALL SELECT 'Supplier', COUNT(*) FROM Supplier
UNION ALL SELECT 'Part', COUNT(*) FROM Part
UNION ALL SELECT 'PartSupp', COUNT(*) FROM PartSupp
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Lineitem', COUNT(*) FROM Lineitem;

SELECT * FROM PartSupp ORDER BY partkey, suppkey;

-- 约束冲突测试：以下 INSERT/DELETE 按实验设计应报错。
INSERT INTO Region (regionkey, name, comment) VALUES (1, '重复地区', '预期主键冲突');

INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES (99, '不存在地区的国家', 999, '预期外键冲突');

INSERT INTO Region (regionkey, name, comment) VALUES (90, '删除测试地区', '外键删除测试');
INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES (90, '删除测试国家', 90, '引用地区 90');
DELETE FROM Region WHERE regionkey = 90;
DELETE FROM Nation WHERE nationkey = 90;
DELETE FROM Region WHERE regionkey = 90;

INSERT INTO Part (partkey, name, retailprice) VALUES (990, '非法价格测试', 0.00);

INSERT INTO PartSupp (partkey, suppkey, availqty, supplycost) VALUES (201, 101, -1, 1.00);

-- 级联删除的 Nation 外键定义：
-- CONSTRAINT FK_Nation_Region FOREIGN KEY (regionkey)
--     REFERENCES Region (regionkey) ON DELETE CASCADE

-- 按国家汇总供应商、零件、库存及供应价格
SELECT
    n.name AS nation_name,
    COUNT(DISTINCT s.suppkey) AS supplier_count,
    COUNT(DISTINCT ps.partkey) AS part_count,
    SUM(ps.availqty) AS total_availqty,
    AVG(ps.supplycost) AS avg_supplycost
FROM Nation AS n
JOIN Supplier AS s ON s.nationkey = n.nationkey
JOIN PartSupp AS ps ON ps.suppkey = s.suppkey
GROUP BY n.nationkey, n.name
HAVING SUM(ps.availqty) > 500
ORDER BY n.nationkey;

-- 查询余额高于本国平均值的顾客
SELECT
    c.name AS customer_name,
    n.name AS nation_name,
    c.acctbal
FROM Customer AS c
JOIN Nation AS n ON n.nationkey = c.nationkey
WHERE c.acctbal > (
    SELECT AVG(c2.acctbal)
    FROM Customer AS c2
    WHERE c2.nationkey = c.nationkey
)
ORDER BY n.nationkey, c.custkey;

-- 加分：查询没有订单的顾客
SELECT c.custkey, c.name
FROM Customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders AS o
    WHERE o.custkey = c.custkey
)
ORDER BY c.custkey;

-- 库存预警日志与触发器
CREATE TABLE StockAlert_Log (
    alert_id INT NOT NULL AUTO_INCREMENT,
    partkey INT NOT NULL,
    suppkey INT NOT NULL,
    alert_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_StockAlert_Log PRIMARY KEY (alert_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER $$
CREATE TRIGGER trg_partsupp_lowstock
AFTER UPDATE ON PartSupp
FOR EACH ROW
BEGIN
    IF NEW.availqty < 10 AND OLD.availqty >= 10 THEN
        INSERT INTO StockAlert_Log (partkey, suppkey)
        VALUES (NEW.partkey, NEW.suppkey);
    END IF;
END$$
DELIMITER ;

UPDATE PartSupp
SET availqty = 5
WHERE partkey = 201 AND suppkey = 102;
SELECT * FROM StockAlert_Log ORDER BY alert_id;

UPDATE PartSupp
SET availqty = 12
WHERE partkey = 202 AND suppkey = 102;
SELECT * FROM StockAlert_Log ORDER BY alert_id;

-- ============================================================
-- 实验课件思考题补充（第 2、3、4、5、7、8 周）
-- ============================================================

-- ------------------------------------------------------------
-- 第 2 周：数据插入与实体/参照完整性观察
-- ------------------------------------------------------------
USE TPCH;

-- 有效的父表-子表插入：先插入 Region，再插入引用它的 Nation。
INSERT INTO Region (regionkey, name, comment)
VALUES (901, '思考题测试地区', '第2周思考题');
INSERT INTO Nation (nationkey, name, regionkey, comment)
VALUES (901, '思考题测试国家', 901, '引用 regionkey=901');

-- 预期报错：1452，regionkey=9999 在 Region 中不存在。
INSERT INTO Nation (nationkey, name, regionkey, comment)
VALUES (9991, '非法引用国家', 9999, '第2周外键测试');

-- 预期报错：1062，regionkey=1 已存在，违反 Region 主键。
INSERT INTO Region (regionkey, name, comment)
VALUES (1, '重复地区测试', '第2周主键测试');

-- 清理有效测试记录：先删除子表 Nation，再删除父表 Region。
DELETE FROM Nation WHERE nationkey = 901;
DELETE FROM Region WHERE regionkey = 901;

-- ------------------------------------------------------------
-- 第 3 周：EXISTS 查询——查询所有未下过订单的顾客
-- ------------------------------------------------------------
SELECT c.custkey, c.name, c.address, c.nationkey, c.phone, c.acctbal,
       c.mktsegment, c.comment
FROM Customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders AS o
    WHERE o.custkey = c.custkey
)
ORDER BY c.custkey;

-- ------------------------------------------------------------
-- 第 4 周：分组统计——统计每个国家的供应商数量
-- ------------------------------------------------------------
SELECT n.nationkey,
       n.name AS nation_name,
       COUNT(s.suppkey) AS supplier_count
FROM Nation AS n
LEFT JOIN Supplier AS s ON s.nationkey = n.nationkey
GROUP BY n.nationkey, n.name
ORDER BY n.nationkey;

-- ------------------------------------------------------------
-- 第 5 周：唯一索引与重复值插入
-- ------------------------------------------------------------
-- 为 Part.name 创建唯一索引；现有测试数据中的零件名称均不重复。
CREATE UNIQUE INDEX UQ_Part_Name_Thought ON Part (name);

-- 预期报错：1062，name='螺栓' 已被唯一索引占用。
INSERT INTO Part (partkey, name, retailprice, comment)
VALUES (9901, '螺栓', 18.00, '第5周唯一索引测试');

-- ------------------------------------------------------------
-- 第 7 周：自主存取控制——auditor 角色与 audit_user 用户
-- ------------------------------------------------------------
-- 需要使用 root 或具有 CREATE USER、ROLE_ADMIN、GRANT OPTION 权限的账号执行。
-- 如 audit_user 已存在，CREATE USER IF NOT EXISTS 不会覆盖其密码。
CREATE ROLE IF NOT EXISTS 'auditor';
GRANT SELECT ON TPCH.* TO 'auditor';
CREATE USER IF NOT EXISTS 'audit_user'@'localhost'
    IDENTIFIED BY 'ChangeMe_25345163!';
GRANT 'auditor' TO 'audit_user'@'localhost';
SET DEFAULT ROLE 'auditor' TO 'audit_user'@'localhost';

-- 权限检查（可在 audit_user 连接中执行）：
-- SELECT CURRENT_USER();
-- SELECT * FROM TPCH.Part LIMIT 5;
-- UPDATE TPCH.Part SET retailprice = retailprice WHERE partkey = 201;
-- 上述 SELECT 应成功；UPDATE 应因仅有 SELECT 权限而失败。

-- ------------------------------------------------------------
-- 第 8 周：列级约束与表级约束的对比
-- ------------------------------------------------------------
-- 列级约束可以改写为表级约束；例如 name 的 UNIQUE 约束有两种写法。
CREATE TABLE Constraint_Column_Level (
    id INT NOT NULL,
    name VARCHAR(30) UNIQUE,
    CONSTRAINT PK_Constraint_Column_Level PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Constraint_Table_Level (
    id INT NOT NULL,
    name VARCHAR(30),
    CONSTRAINT PK_Constraint_Table_Level PRIMARY KEY (id),
    CONSTRAINT UQ_Constraint_Table_Level_Name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 表级约束不能都改写为列级约束；复合主键必须在表级定义。
CREATE TABLE Constraint_Composite_Key (
    partkey INT NOT NULL,
    suppkey INT NOT NULL,
    availqty INT,
    CONSTRAINT PK_Constraint_Composite_Key PRIMARY KEY (partkey, suppkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 结论验证：实体完整性要求主键值唯一且非空；插入重复主键时 DBMS 拒绝该操作，
-- 通常返回错误 1062，当前语句失败但已有合法记录不受影响。
INSERT INTO Constraint_Composite_Key (partkey, suppkey, availqty)
VALUES (1, 1, 10);
-- 预期报错：1062，复合主键 (1,1) 重复。
INSERT INTO Constraint_Composite_Key (partkey, suppkey, availqty)
VALUES (1, 1, 20);


