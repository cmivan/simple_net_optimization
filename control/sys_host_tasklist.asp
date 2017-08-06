<!--#include file="include/conn.asp"-->
<%
dim host_id
    host_id = request("host_id")

'获取主机信息
if host_id<>"" and isnumeric(host_id) then session("host_id") = host_id
host_id = session("host_id")
if host_id="" or isnumeric(host_id)=false then
   response.write("Place select the host!")
   response.end
end if

'任务处理：发送删除命令
dim action,tasks,mr
   action = request("action")
if action = "send.cmd" then
   tasks = request("tasks")
   mr = request("mr")
   if tasks="" then response.write("Place select the task!"):response.end  
   if mr<>"" and mr="1" then
      mrStr = "Set default!"
      mr = 1
   else
      mrStr = "The Common!"
      mr = 0
   end if
   if host_id=0 then
      '向全部主机发送
      call taskkill_cmd_all(tasks,mr)
   else
      '被选中的主机发送
      call taskkill_cmd(host_id,tasks,mr)
   end if
   if mr=1 then call taskkill_MR(tasks)
   response.write("sending cmd ok!"&mrStr)
   response.end
end if


if action="rename" then
    task_id = request("taskID")
    hostuser= request("hostuser")
    if task_id<>"" and isnumeric(task_id) then
       if hostuser="" then response.write("Name？"):response.end
       conn.execute("update sys_tasklist set [note]='"&hostuser&"' where id="&task_id)
       response.write(hostuser)
    else
       response.write("Host id falie!")
    end if
    response.end
end if

'///////////////////////////////////////////
dim lists,thislists
    thislists = "|o|"
    
if host_id=0 then
    lists = "|"
    set rs=conn.execute("select * from sys_tasklist order by MR desc,exename asc")
        do while not rs.eof
           lists = lists&rs("id")&"|"
        rs.movenext
        loop
    set rs=nothing
else
    set rs=conn.execute("select top 1 * from tasklist where hostid = "&host_id&" order by updatetime desc")
        if not rs.eof then lists = rs("list")
    set rs=nothing
end if


if lists<>"" then
 if (md5(lists) <> session("TaskMD5") and request("host_id")="") or request("host_id")<>"" then
    session("TaskMD5") = md5(lists)
%>
<script type="text/javascript" src="style/validform/js/validform.js"></script>
<script type="text/javascript">
$(function(){	   
  $(".tasklist td").hover(
	function(){$(this).attr('class','over');},
	function(){$(this).attr('class','');}
	);
  $(".tasklist td").click(function(){
	  var checked = $(this).find('input').attr('checked');
	  if(checked){checked=false;}else{checked=true;}
	  $(this).find('input').attr('checked',checked);
	  });
  $("#checkall").click(function(){
	  var checked = $(this).attr('checked');
	  if(checked){checked=false;}else{checked=true;}
	  $('input').attr('checked',checked);
  });
  $("#PT_endlist").click(function(){ SendCMD(GetTASKS(),'0'); });
  $("#MR_endlist").click(function(){ SendCMD(GetTASKS(),'1'); });
  
  //编辑进程描述
  $(".hostuser").click(function(){
	$(this).find("input").css({"display":"block"});	
	$(this).find("label").css({"display":"none"});	
	});
  $(".hostuser").find("input").blur(function(){
	$(this).parent().find("input").css({"display":"none"});	
	$(this).parent().find("label").css({"display":"block"});
	var taskid = $(this).parent().attr('taskid');
	var hostuser = $(this).val();
	if(hostuser!=null&&hostuser!=''){
		hostuser = encodeURI(hostuser);
		$(this).parent().find("label").load('sys_host_tasklist.asp?action=rename&taskid='+taskid+'&hostuser='+hostuser+'&T='+Math.random());
		}
	});
});

//获取被选中的任务ID
function GetTASKS(){
	var taskID,listitems;
	listitems = '';
	
	$("#cmd_load").html('<span id="cmd_loading">&nbsp;</span>');
	//获取被选中的任务ID
	$("input[type=checkbox]:checked").each(function(){
			taskID = $(this).val();	
			if(taskID!=null&&taskID!=''){ listitems = listitems + taskID + '|'; }
		});
	//存在选中的任务ID则发送命令
	if(listitems!=''){ listitems = '|' + listitems; }
	return listitems;
	}
//发送被选中的任务
function SendCMD(TASKS,MR){
	$("#cmd_load").show();
	$("#cmd_load").load('sys_host_tasklist.asp?action=send.cmd&tasks='+TASKS+'&mr='+MR,function(){$("#cmd_load").fadeOut(3000);});
	}
</script>
<div class="tasklist">
<table width="100%" border="0" cellpadding="0" cellspacing="3">
<tr>
  <td colspan="2">&nbsp;<a href="javascript:void(0);" id="PT_endlist">普通结束进程</a>&nbsp;&nbsp;<a href="javascript:void(0);" id="MR_endlist">默认结束进程</a>&nbsp;&nbsp;&nbsp;&nbsp;<span id="cmd_load"></span></td></tr>
<%
  listarr = split(lists,"|")
  listnum = ubound(listarr)
  if listnum>0 then
     for i=0 to listnum
         listID = listarr(i)
         if listID<>"" and isnumeric(listID) then
            if instr(thislists,"|"&listID&"|")<=0 then
               taskname = taskinfo(listID,"exename")
               hostuser = taskinfo(listID,"note")
               MR = taskinfo(listID,"MR")
%>
<tr>
<td width="28%">
<label><input type="checkbox" name="checkbox" id="checkbox" class="taskitem" value="<%=listID%>" <%if MR=1 then response.write("checked=checked")%>>&nbsp;<%=taskname%></label></td><td>
<div class="hostuser" taskid="<%=listID%>" style="width:auto"><input value="<%=hostuser%>" style="width:430px" /><label><%=hostuser%></label></div>
</td></tr>
<%
            end if
            thislists = thislists&listID&"|"
         end if
     next
%>
<tr><td><label><input type="checkbox" name="checkall" id="checkall"> 全选&nbsp;&nbsp;&nbsp;</label></td><td>&nbsp;</td></tr>

<% 
  end if
  response.write("</table></div>")
  else
  response.write("null")
 end if
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end if
%>