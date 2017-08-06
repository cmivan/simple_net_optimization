<!--#include file="include/conn.asp"-->
<script type="text/javascript">
$(function(){
  $(".hostlist .item").hover(
	function(){$(this).css({"background-color":"#000"});},
	function(){$(this).css({"background-color":""});}
  );
  $(".hostlist .item").click(function(){
	  var host_id = $(this).attr('hostid');
	  var hosturl= 'sys_host_tasklist.asp?host_id=' + host_id + '&T=' + Math.random();
	  pageTO('#cmdbox',hosturl,true); 
  });
  
  $("#all_host").click(function(){ pageTO('#cmdbox','sys_host_list2.asp',true); });
  
});
</script>
<div class="item" id="all_host">局网主机列表</div>
<div class="item" hostid="0">全部主机进程</div>
<%
set rs=conn.execute("select * from host where datediff('s',update_time,'"&now()&"')<11")
  do while not rs.eof
%>
<div class="item" hostid="<%=rs("id")%>"><%=rs("ip")%><br /><span>{<%=rs("user")%>}</span></div>
<%
  rs.movenext
  loop
set rs=nothing
%>
<div class="item" id="Times">0</div>