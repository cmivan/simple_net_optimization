<%
'@@@ 创建或更新主机信息
sub hostat(IP,MAC,MACMD5,AGENT)
	 set rs=conn.execute("select top 1 * from host where MACMD5='"&MACMD5&"'")
		if not rs.eof then
		   conn.execute("update host set ip='"&IP&"',agent='"&AGENT&"',update_time='"&now()&"' where MACMD5='"&MACMD5&"'")
		else
		   conn.execute("insert into host (ip,MAC,MACMD5,agent,update_time) values('"&IP&"','"&MAC&"','"&MACMD5&"','"&AGENT&"','"&now()&"')")
		end if
	 set rs=nothing
end sub


'@@@ 根据mac获取主机id
function hostid(macMD5)
    if macMD5<>"" then
       set rs_mac=conn.execute("select id from host where macMD5='"&macMD5&"'")
       if not rs_mac.eof then hostid = rs_mac("id")
       set rs_mac=nothing
    end if
end function

'@@@ 根据进程名称获取进程返回进程
function taskid(exeMD5)
    if exeMD5<>"" then
       set rs_exe=conn.execute("select id from sys_tasklist where exeMD5='"&exeMD5&"'")
       if not rs_exe.eof then taskid = rs_exe("id")
       set rs_exe=nothing
    end if
end function

'@@@ 根据进程id获取进程信息
function taskinfo(id,key)
    if id<>"" and isnumeric(id) then
       set rs_exe=conn.execute("select "&key&" from sys_tasklist where id="&id)
       if not rs_exe.eof then taskinfo = rs_exe(key)
       set rs_exe=nothing
    end if
end function


'@@@ 将获取到的进程列表写入 sys_tasklist(不重复写入)
'返回该任务程序在 sys_tasklist 表中的ids
function tasks2sysID(TASKLIST)
     dim exeMD5,TASKLISTARR,TASKITEMARR,TASKITEM,TASKLIST_ID,TASKLIST_IDS
     if TASKLIST<>"" then
        TASKLISTARR = split(TASKLIST,"|")
        if ubound(TASKLISTARR)>1 then
           for i=1 to ubound(TASKLISTARR)
               TASKITEMARR = split(TASKLISTARR(i),",")
               if ubound(TASKITEMARR)=1 then
                  TASKITEM = TASKITEMARR(1)
                  if TASKITEM<>"" then
                     TASKITEM = lcase(TASKITEM)
                     exeMD5 = md5(TASKITEM)
                     set rs_task = conn.execute("select id from sys_tasklist where exeMD5='"&exeMD5&"'")
                     if rs_task.eof then
                         conn.execute("insert into sys_tasklist (exename,exeMD5) values('"&TASKITEM&"','"&exeMD5&"')")
                     end if
                     set rs_task = nothing
                     TASKLIST_ID = taskid(exeMD5)
                     if TASKLIST_ID<>"" then TASKLIST_IDS = TASKLIST_IDS & "|" & TASKLIST_ID
                  end if
               end if
           next
        end if
     end if
     
     tasks2sysID = TASKLIST_IDS
end function


'@@@ 根据数组，返回任务列表ID
function taskarr2sysID(TASKLIST)
     dim exeMD5,TASKLISTARR,TASKITEMARR,TASKITEM,TASKLIST_ID,TASKLIST_IDS
    if TASKLIST<>"" then
       TASKLISTARR = split(TASKLIST,"|")
       if ubound(TASKLISTARR)>0 then
          for i=0 to ubound(TASKLISTARR)
             TASKITEM = TASKLISTARR(i)
             if TASKITEM<>"" then
                 TASKITEM = lcase(TASKITEM&".exe")
                 exeMD5 = md5(TASKITEM)
                 set rs_task = conn.execute("select id from sys_tasklist where exeMD5='"&exeMD5&"'")
                 if rs_task.eof then
                     conn.execute("insert into sys_tasklist (exename,exeMD5) values('"&TASKITEM&"','"&exeMD5&"')")
                 end if
                 set rs_task = nothing
                 TASKLIST_ID = taskid(exeMD5)
                 if TASKLIST_ID<>"" then TASKLIST_IDS = TASKLIST_IDS & "|" & TASKLIST_ID
             end if
          next
       end if
    end if
    taskarr2sysID = TASKLIST_IDS
end function

'@@@ 创建配置列表
function taskconfig(taskarr,default)
   dim taskarrs,tasknum,taskitem,taskitems,taskkey
   taskarrs = split(taskarr,"|")
   tasknum = ubound(taskarrs)
   if tasknum>0 then
       for i=0 to tasknum
          taskitem = taskarrs(i)
          if taskitem<>"" then
             taskkey = taskinfo(taskitem,"exename")
             if taskkey<>"" then
                taskkey = replace(taskkey,".exe","")
                taskitems = taskitems&chr(10)&taskkey
             end if
          end if
       next
   end if
   if (taskitems<>"" and default=1) then
      taskitems = "[default]"&lcase(taskitems)
   end if
   taskconfig = taskitems
end function


'@@@ 设置默认列表
function taskkill_MR(taskarr)
   dim taskarrs,tasknum,taskitem
   taskarrs = split(taskarr,"|")
   tasknum = ubound(taskarrs)
   if tasknum>0 then
       conn.execute("update sys_tasklist set MR=0")
       for i=0 to tasknum
          taskitem = taskarrs(i)
          if taskitem<>"" and isnumeric(taskitem) then
             conn.execute("update sys_tasklist set MR=1 where id="&taskitem)
          end if
       next
   end if  
end function


'@@@ 单台主机添加新删除进程任务
function taskkill_cmd(id,tasks,mr)
    dim cmdMD5
    if id<>"" and isnumeric(id) and tasks<>"" and isnumeric(mr) then
       cmdMD5 = md5(id&tasks&mr)
       set rs_tk = conn.execute("select id from taskclear where cmdMD5='"&cmdMD5&"' and ok=0")
           if rs_tk.eof then
              conn.execute("insert into taskclear (hostid,taskcmd,taskback,default,ok,cmdMD5) values("&id&",'"&tasks&"','',"&mr&",0,'"&cmdMD5&"')")
           end if
       set rs_tk = nothing
    end if
end function

'@@@ 全部主机添加新删除进程任务
function taskkill_cmd_all(tasks,mr)
    if tasks<>"" and isnumeric(mr) then
       set rs_cmd = conn.execute("select * from host order by id desc")
           do while not rs_cmd.eof
              taskkill_cmd rs_cmd("id"),tasks,mr
           rs_cmd.movenext
           loop
       set rs_cmd = nothing
    end if
end function
%>