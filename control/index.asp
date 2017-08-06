<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--#include file="include/conn.asp"-->
<html>
<head>
<title>齐翔网络管理程序 v1.0</title>
<meta name="viewport" content="width=1060px" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="style/screen.css" type="text/css" />
<script type="text/javascript" src="style/jquery1.4.js"></script>
<script type="text/javascript" src="style/validform/js/validform.js"></script>
<script type="text/javascript" src="style/main.js"></script>
<script type="text/javascript">
var Times,TflashSec;
    Times=6; //每60秒刷新一下
	TflashSec=Times;
$(function(){ ajaxpages(); });
function ajaxpages(){
	pageTO('.hostlist','sys_host_list.asp',false);
	pageTO('#cmdbox','sys_host_tasklist.asp',false);
	}
function hosttimer(){
	$("#Times").text(Times);
	if(Times==0){Times=TflashSec;ajaxpages();}
	Times--;
	}
setInterval(hosttimer,1000);
</script>
</head>
<body>
<div id="main" class="default">
<div id="main_inner">    
<div id="header">
<div class="inside">
<div class="logo"><img src="style/images/logo.png" width="307" height="122">
</div>
</div>
</div>
</div>

<div class="clear"></div>
<div class="content">

<div class="inside">

<div class="hostlist"></div>

<div class="hostcmd"><div id="cmdbox"></div></div>

</div>
</div></div>
<br /><br />
</body>
</html>