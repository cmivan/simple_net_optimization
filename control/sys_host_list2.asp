<!--#include file="include/conn.asp"-->
<%
 action = request("action")
 if action="rename" then
    host_id = request("host_id")
    hostuser= request("hostuser")
    if host_id<>"" and isnumeric(host_id) then
       if hostuser="" then response.write("Name？"):response.end
       conn.execute("update host set user='"&hostuser&"' where id="&host_id)
       response.write(hostuser)
    else
       response.write("Host id falie!")
    end if
    response.end
 end if
%>
<script type="text/javascript">
$(function(){	   
  $(".tasklist td").hover(
	function(){$(this).attr('class','over');},
	function(){$(this).attr('class','');}
	);
  $(".hostuser").click(function(){
	$(this).find("input").css({"display":"block"});	
	$(this).find("label").css({"display":"none"});	
	});
  $(".hostuser").find("input").blur(function(){
	$(this).parent().find("input").css({"display":"none"});	
	$(this).parent().find("label").css({"display":"block"});
	var hostid = $(this).parent().attr('hostid');
	var hostuser = $(this).val();
	if(hostuser!=null&&hostuser!=''){
		$(this).parent().find("label").load('sys_host_list2.asp?action=rename&host_id='+hostid+'&hostuser='+hostuser+'&T='+Math.random());
		}
	});
});

</script>
<div class="tasklist">
<table width="100%" border="0" cellpadding="0" cellspacing="3">
<tr>
<td>IP</td>
<td>MAC</td>
<td>AGENT</td>
<td>USER</td>
</tr>
<%
set rs=conn.execute("select * from host")
    do while not rs.eof
%>
<tr title="<%=rs("agent")%>">
<td><%=rs("ip")%></td>
<td><%=rs("mac")%></td>
<td><%=rs("update_time")%></td>
<td><div class="hostuser" hostid="<%=rs("id")%>"><input value="<%=rs("user")%>" /><label><%=rs("user")%></label></div></td>
</tr>
<%
    rs.movenext
    loop
set rs=nothing
%>
</table>

</div>