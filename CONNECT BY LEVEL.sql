----CONNECT BY LEVEL for generating sequence of numbers----

select level as c_number
from dual
connect by level <=100;

