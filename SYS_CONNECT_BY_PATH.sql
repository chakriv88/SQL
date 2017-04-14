----SYS_CONNECT_BY_PATH displays hierarchy of a row at column level----

select first_name, job_title, manager, level,
sys_connect_by_path(first_name,'/') as path
from salesperson
connect by prior
first_name = manager
start with
manager is null order by 4;

