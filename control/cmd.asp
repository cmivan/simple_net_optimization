<!--#include file="include/conn.asp"-->
<%

' 2011-8-1
' 提交命令操作并记录在数据库中
' By :  cmivan

 '@@@@@@@@@@@@@@@@@@@@@@@@@@@
  dim MAC,TASKLIST,TASKBACK,TASKCMD,MACMD5,CMD
      MAC = request("MAC")
	  TASKLIST = request("TASKLIST")
	  TASKBACK = request("TASKBACK")
	  if MAC="" then response.End() 
      MACMD5 = md5(lcase(MAC))
      
 '@@@@@@@@@@@@@@@@@@@@@@@@@@@
  dim host_id
  dim TASKLIST_IDS    

	  
 '部分操作需要选择主机后才可以执行
  if MACMD5<>"" then

	 '### 新增 或 更新主机信息
	  call hostat(IP,MAC,MACMD5,AGENT)
     
     '### 获取主机id
      host_id = hostid(MACMD5)
      
     '### 获取该用户的任务id值
      TASKLIST_IDS = tasks2sysID(TASKLIST)

	 '### 记录用户当前的tasklist列表
     if TASKLIST_IDS<>"" then
	    TASKLIST_MD5 = md5(TASKLIST_IDS)
        TASKLIST_IDS = TASKLIST_IDS&"|"
	    set rs=conn.execute("select top 1 * from tasklist where listMD5='"&TASKLIST_MD5&"'")
		    if not rs.eof then
			   conn.execute("update tasklist set updatetime='"&now()&"' where id="&rs("id"))
			else
			   conn.execute("insert into tasklist (hostid,listMD5,list) values("&host_id&",'"&TASKLIST_MD5&"','"&TASKLIST_IDS&"')")
		    end if
	    set rs=nothing
     end if




	 '### 判断并记录提交的命令
     TASKBACK = taskarr2sysID(TASKBACK)
	 set rs=conn.execute("select top 1 * from taskclear where hostid="&host_id&" and ok=0 order by ok desc")
		 if not rs.eof then
            '### 记录用户当前的tasklist的清除信息列表
            if TASKBACK<>"" then conn.execute("update taskclear set ok=1,taskback='"&TASKBACK&"',updatetime='"&now()&"' where ok=0 and hostid="&host_id&" and id="&rs("id"))
			TASKCMD = taskconfig(rs("taskcmd"),rs("default"))
            if TASKCMD<>"" then
               response.write(TASKCMD)
            else
               conn.execute("update taskclear set ok=1,updatetime='"&now()&"' where id="&rs("id"))
            end if
         else
            '### 不存在记录但是有返回，则记录
            if TASKBACK<>"" then conn.execute("insert into taskclear (hostid,ok,taskback,T) values("&host_id&",1,'"&TASKBACK&"',1)")
		 end if
	 set rs=nothing

  end if
 %>