------------------------- TABLES ------------------------------------------
create table users_sTtFVc(
	username varchar(300) UNIQUE,
	balance int,
	magic varchar(300) UNIQUE,
	visible bit,
	YzNaYONpzT int
);

create table roles_sTtFVc(
	mHash varchar(300),
	role varchar(300)
);

create table passwords_sTtFVc(
	username varchar(300),
	password varchar(50),
	expired bit
);

--------------------- INIT WITH DATA ----------------------------------
Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;

DO $$
DECLARE username varchar(300);
DECLARE magic varchar(300);
DECLARE balance int;
DECLARE password varchar(300);
DECLARE hMagic varchar(300);
DECLARE role varchar(300);
DECLARE YzNaYONpzT int;

-- THIS IS THE ANSWER
DECLARE adminPass varchar(50) DEFAULT 'Dubskih';

-- Where to place admin record
DECLARE adminIdx int DEFAULT 753;

DECLARE i int DEFAULT 0;

BEGIN
	WHILE i < 1000 LOOP
		username = random_string(15);
		magic = random_string(15);
		balance=((random()*1000)::int);
		password = random_string(15);
		hMagic= md5(username);
		role=random_string(15);
		YzNaYONpzT = ((random()*1000)::int);
		
		IF i = adminIdx THEN
           password = adminPass;
           role = 'admin';
       	END IF;
		
		INSERT INTO users_sTtFVc VALUES (username, balance, magic, ROUND(random())::int::bit, YzNaYONpzT);
		INSERT INTO roles_sTtFVc VALUES (hMagic, role);
		INSERT INTO passwords_sTtFVc VALUES (username, password, ROUND(random())::int::bit);
			
		i = i + 1;
	END LOOP;

END $$;

--------------------- PROCEDURES --------------------------------------
create or replace function GetUserInfo(u varchar(300))
returns table ( username varchar(300),
				balance int,
				magic varchar(300),
				visible bit,
				YzNaYONpzT int)
language plpgsql as $$
begin
	u = FilterFunc(u);
    return query 
    EXECUTE('select * from users_sTtFVc where username = ' || u || ' and visible = 1::bit');
end;$$;

CREATE or replace function GetBalance (u varchar(300))
returns int
language plpgsql as $$
BEGIN
	DROP table if exists tmp;
	CREATE TEMP table tmp(
		username varchar(300),
		balance int,
		magic varchar(300),
		visible bit,
		YzNaYONpzT int
	
	);
	--special filter to disallow JOIN
	u = REPLACE(u, 'j', '');
	u = FilterFunc(u);
	RAISE NOTICE 'Clear username %', u;
	INSERT INTO tmp select * from GetUserInfo (''''||u||'''');
	RETURN(SELECT balance from tmp);
end;$$;



CREATE or replace function CPE (u varchar(300))
returns table (b bit)
language plpgsql as $$
BEGIN
	return query EXECUTE('SELECT expired from passwords_sTtFVc where username = ' || u);
END;$$;

CREATE or replace function CheckPasswordExpired (u varchar(300))
returns table (b bit)
language plpgsql as $$
BEGIN
	--u = FilterFunc(u);
	
	DROP table if exists tmp;
	CREATE TEMP TABLE tmp (b bit);
	INSERT INTO tmp SELECT * from CPE(''''||u||'''');
	return query SELECT * FROM tmp;
END;$$;

CREATE OR REPLACE FUNCTION HA(u varchar(300))
RETURNS TABLE(r varchar(300)) LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY EXECUTE('SELECT username FROM users_sTtFVc JOIN roles_sTtFVc ON mhash = md5(username) WHERE balance % 2 = 1 AND username = ' || u || ' OR role = ''admin'' LIMIT 1;');
END;
$$;

CREATE OR REPLACE FUNCTION HasAccess(u varchar(300)) RETURNS int LANGUAGE plpgsql
AS $$
BEGIN
    u = FilterFunc(u);
    DROP TABLE tmp;
    CREATE TEMP TABLE tmp (b varchar(300));
	INSERT INTO tmp
    SELECT * FROM HA(''''||u||'''');
    RETURN (SELECT count(*) FROM tmp);
END;$$;

------------------FUNCTIONS------------
-- simple filter to remove /**/
CREATE or replace FUNCTION CommentsFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql
as $$
BEGIN
	RETURN (SELECT REPLACE(q, '/**/', ''));
END;$$;

-- simple filter to remove select (case insensitive)
CREATE or replace FUNCTION SelectFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, 'select', ''));
END;$$;

-- simple filter to remove from (case insensitive)
CREATE or replace FUNCTION FromFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, 'from', ''));
END;$$;

-- simple filter to remove whitespaces
CREATE or replace FUNCTION WhiteSpaceFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	-- remove spaces
	q =  REPLACE(q, ' ', '');
	-- remove tabs
	RETURN (SELECT REPLACE(q, '	', ''));
END;$$;

-- filter admin word
CREATE or replace FUNCTION AdminFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, 'admin', ''));
END;$$;

-- filter = symbol
CREATE or replace FUNCTION EqualFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, '=', ''));
END;$$;

-- filter quotes
CREATE or replace FUNCTION QuotesFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, '''', ''));
END;$$;

-- filter = symbol
CREATE or replace FUNCTION NullFilter(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	RETURN (SELECT REPLACE(q, 'NULL', ''));
END;$$;

CREATE or replace FUNCTION FilterFunc(q varchar(300))
RETURNS varchar(300)
language plpgsql as $$
BEGIN
	q = CommentsFilter(q);
	q = SelectFilter(q);
	q = FromFilter(q);
	q = WhiteSpaceFilter(q);
	q = AdminFilter(q);
	q = EqualFilter(q);
	q = QuotesFilter(q);
	q = NullFilter(q);
	RETURN q;
END;$$;
