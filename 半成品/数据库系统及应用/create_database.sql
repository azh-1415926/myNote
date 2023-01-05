CREATE DATABASE 仓储订货;
USE 仓储订货;
CREATE SCHEMA 仓储;
CREATE SCHEMA 基础;
CREATE SCHEMA 订货;
CREATE TABLE 仓储.仓库(
    仓库号 CHAR(6) PRIMARY KEY,
    城市 CHAR(10),
    面积 INT CHECK(面积>0)
);
INSERT INTO 仓储.仓库(仓库号,城市,面积) VALUES
    ('WH1','北京',500),
    ('WH2','上海',370),
    ('WH3','广州',300),
    ('WH4','武汉',400);
CREATE TABLE 基础.职工(
    仓库号 CHAR(6) CONSTRAINT ref_wh
        FOREIGN KEY REFERENCES 仓储.仓库(仓库号),
    职工号 CHAR(8) PRIMARY KEY,
    姓名 CHAR(10),
    工资 numeric(8,2)
        CHECK(工资>=2000 AND 工资<=8000)
        DEFAULT 4200,
    班组长 CHAR(8) FOREIGN KEY REFERENCES 基础.职工(职工号)
);
INSERT INTO 基础.职工(仓库号,职工号,姓名,工资,班组长) VALUES
    ('WH1','E2','王月',4220,NULL),
    ('WH1','E7','张扬',4250,'E2'),
    ('WH1','E8','陈虹',4440,'E7'),
    ('WH1','E9','方林',4480,'E7'),
    ('WH2','E4','李星',4250,NULL),
    ('WH2','E1','吴臣',4200,'E4'),
    ('WH2','E3','于险',4550,'E4'),
    ('WH3','E6','姚思',4420,NULL),
    ('WH3','E5','韩喜',4270 ,'E6'),
    ('WH4','E11','吴霞',4270,'E6'),
    (NULL,'E12','吴秋',4500,'E5');
CREATE TABLE 订货.供应商(
    供应商号 CHAR(5) PRIMARY KEY,
    供应商名 CHAR(20),
    地址 CHAR(20)
)
INSERT INTO 订货.供应商(供应商号,供应商名,地址) VALUES
    ('S3','振兴电子厂','西安'),
    ('S4','华通电子公司','北京'),
    ('S6','世纪金梦公司','郑州'),
    ('S7','爱华电子厂','北京')
CREATE TABLE 订货.订购单(
    订购单号 CHAR(5) PRIMARY KEY,
    经手人 CHAR(8) NOT NULL FOREIGN KEY REFERENCES 基础.职工(职工号),
    供货方 CHAR(5) NULL FOREIGN KEY REFERENCES 订货.供应商(供应商号),
    订购日期 DATETIME DEFAULT getdate(),
    金额 MONEY NULL
)
ALTER TABLE 订货.订购单
ADD 完成日期 datetime
INSERT INTO 订货.订购单(订购单号,经手人,供货方,订购日期) VALUES
    ('OR67','E3','S7','2017/01/23'),
    ('OR73','E1','S4','2017/02/04'),
    ('OR76','E7','S4','2017/02/04'),
    ('OR77','E6',NULL,NULL),
    ('OR79','E3','S4','2017/01/13'),
    ('OR80','E1',NULL,NULL),
    ('OR90','E3',NULL,NULL),
    ('OR91','E3','S3','2017/01/13')
SELECT * FROM 仓储.仓库
SELECT * FROM 基础.职工
SELECT * FROM 订货.供应商
SELECT * FROM 订货.订购单