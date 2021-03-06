/*
   [이것이 Oracle이다] 소스 코드
   9장. 인덱스
*/

------------------------------------
-- 9.2 인덱스의 종류와 자동 생성 
------------------------------------

----------------- <실습 1> -------------------
CREATE TABLE  tbl1
	(	a NUMBER(4) PRIMARY KEY,
		b NUMBER(4),
		c NUMBER(4)
	);

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='TBL1' ;
    
CREATE TABLE  tbl2
	(	a NUMBER(4) PRIMARY KEY,
		b NUMBER(4) UNIQUE,
		c NUMBER(4) UNIQUE,
		d NUMBER(4)
	);

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='TBL2' ;

----------------- </실습 1> -------------------    


------------------------------------
-- 9.3 인덱스의 내부 작동
------------------------------------

CREATE TABLE btreeTBL
( userID  CHAR(8) ,
  userName    NVARCHAR2(10) 
);
INSERT INTO btreeTBL VALUES('LSG', '이승기');
INSERT INTO btreeTBL VALUES('KBS', '김범수');
INSERT INTO btreeTBL VALUES('KKH', '김경호');
INSERT INTO btreeTBL VALUES('JYP', '조용필');
INSERT INTO btreeTBL VALUES('SSK', '성시경');
INSERT INTO btreeTBL VALUES('LJB', '임재범');
INSERT INTO btreeTBL VALUES('YJS', '윤종신');
INSERT INTO btreeTBL VALUES('EJW', '은지원');
INSERT INTO btreeTBL VALUES('JKW', '조관우');
INSERT INTO btreeTBL VALUES('BBK', '바비킴');

SELECT rowid, userID, userName FROM btreeTBL;

ALTER TABLE btreeTBL
	ADD CONSTRAINT PK_btreeTBL_userID
		PRIMARY KEY (userID);

INSERT INTO btreeTBL VALUES('FNT', '푸니타');
INSERT INTO btreeTBL VALUES('KAI', '카아이');


------------------------------------
-- 9.4 인덱스 생성/변경/삭제 
------------------------------------

----------------- <실습 2> -------------------    


ALTER TABLE userTBL -- PK 제거
    DROP PRIMARY KEY CASCADE;
ALTER TABLE userTBL -- PK 생성
    ADD CONSTRAINT PK_userTBL_userID PRIMARY KEY(userID);
ALTER TABLE buyTbl -- FK 생성
    ADD CONSTRAINT FK_userTbl_buyTbl 
    FOREIGN KEY (userID) 
    REFERENCES userTBL(userID) ;

SELECT * FROM userTbl;

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='USERTBL' ;

SELECT INDEX_NAME, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS FROM  USER_INDEXES 
    WHERE TABLE_NAME='USERTBL' ;

SELECT * FROM userTBL WHERE userID='BBK';

SELECT * FROM userTBL WHERE userName='바비킴';

CREATE INDEX idx_userTbl_addr 
   ON userTbl (addr);

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='USERTBL' ;

SELECT INDEX_NAME, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS FROM  USER_INDEXES 
    WHERE TABLE_NAME='USERTBL' ;

CREATE UNIQUE INDEX idx_userTbl_birtyYear
	ON userTbl (birthYear);

CREATE UNIQUE INDEX idx_userTbl_userName
	ON userTbl (userName);

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='USERTBL' ;

SELECT INDEX_NAME, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS FROM  USER_INDEXES 
    WHERE TABLE_NAME='USERTBL' ;    
    
INSERT INTO userTbl VALUES('GPS', '김범수', 1983, '미국', NULL  , NULL  , 162, NULL);

CREATE INDEX idx_userTbl_userName_birthYear
	ON userTbl (userName,birthYear);
DROP INDEX idx_userTbl_userName;

SELECT I.INDEX_NAME, I.INDEX_TYPE, I.UNIQUENESS, C.COLUMN_NAME, C.DESCEND
    FROM USER_INDEXES I
        INNER JOIN USER_IND_COLUMNS C
        ON I.INDEX_NAME = C.INDEX_NAME
    WHERE I.TABLE_NAME='USERTBL' ;

SELECT * FROM userTbl WHERE userName = '윤종신' and birthYear = '1969';

SELECT * FROM userTbl WHERE userName = '윤종신';

CREATE INDEX idx_userTbl_mobile1
	ON userTbl (mobile1);

SELECT * FROM userTbl WHERE mobile1 = '011';

SELECT INDEX_NAME FROM  USER_INDEXES 
    WHERE TABLE_NAME='USERTBL';

DROP INDEX idx_userTbl_addr;
DROP INDEX idx_userTbl_userName_birthYear;
DROP INDEX idx_userTbl_mobile1;

DROP INDEX PK_userTBL_userID;

ALTER TABLE userTBL
	DROP PRIMARY KEY;

SELECT * FROM USER_CONSTRAINTS 
    WHERE OWNER='SQLDB' AND TABLE_NAME='BUYTBL' AND CONSTRAINT_TYPE='R';

ALTER TABLE userTBL
	DROP PRIMARY KEY CASCADE;
    
----------------- </실습 2> -------------------    



------------------------------------
-- 9.5 인덱스의 성능 비교
------------------------------------

----------------- <실습 3> -------------------    

SELECT COUNT(*) FROM HR.bigEmployees;

CREATE TABLE Emp AS 
    SELECT * FROM HR.bigEmployees ORDER BY DBMS_RANDOM.VALUE;
CREATE TABLE Emp_idx AS 
    SELECT * FROM HR.bigEmployees ORDER BY DBMS_RANDOM.VALUE;

SELECT * FROM Emp WHERE ROWNUM <= 5;
SELECT * FROM Emp_idx WHERE ROWNUM <= 5;

SELECT * FROM  USER_INDEXES
    WHERE TABLE_NAME='EMP';

CREATE INDEX idx_empIdx_emoNo ON Emp_idx(emp_no);

SELECT INDEX_NAME, INDEX_TYPE, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS FROM  USER_INDEXES 
    WHERE TABLE_NAME='EMP_IDX' ;

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM Emp WHERE emp_no = 20000; -- 사원번호 20000인 사람 1명을 조회

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM Emp_idx WHERE emp_no = 20000;

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM Emp WHERE emp_no < 10100;  -- 약 99건을 조회함

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM Emp_idx WHERE emp_no < 10100;  

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM Emp_idx WHERE emp_no < 11000; -- 약 999건을 조회함

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

SELECT /*+ INDEX(Emp_idx IDX_EMPIDX_EMONO) */ 
    * FROM Emp_idx WHERE emp_no < 11000;
    

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;    

SELECT * FROM Emp_idx WHERE emp_no < 10500; -- 약 499건을 조회함

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;    

SELECT * FROM Emp_idx WHERE emp_no < 10400; -- 약 399건을 조회함

SELECT * FROM Emp_idx WHERE emp_no = 20000;

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;  

SELECT * FROM Emp_idx WHERE emp_no*1 = 20000;

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;  

SELECT * FROM Emp_idx WHERE emp_no = 20000/1;

SELECT * FROM Emp;

CREATE INDEX idx_Emp_gender ON Emp (gender); 
SELECT INDEX_NAME, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS FROM  USER_INDEXES 
    WHERE TABLE_NAME='EMP' ;

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;  

SELECT * FROM Emp WHERE gender = 'M';

ALTER INDEX idx_Emp_gender REBUILD;
----------------- </실습 3> -------------------    

------------------------------------
-- 9.6 결론: 인덱스를 생성해야 하는 경우와 그렇지 않은 경우
------------------------------------

SELECT name, birthYear, addr FROM userTbl WHERE userID = 'KKH';



