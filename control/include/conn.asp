<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<% Response.CodePage=65001%>
<% Response.Charset="UTF-8" %>
<%
on error resume next
dim conn,connstr
    connstr="DRIVER=Microsoft Access Driver (*.mdb);DBQ="&server.mappath("include/host.mdb")
Set conn=Server.CreateObject("ADODB.Connection") 
    conn.Open connstr
 If Err Then
    Err.Clear
    Set conn = Nothing
    Response.Write "by cmivan!"
    Response.End
 End If

'客户端信息
Dim IP,AGENT
    IP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
    If IP = "" Then IP = Request.ServerVariables("REMOTE_ADDR")
'客户端协议
    AGENT = Request.ServerVariables("HTTP_USER_AGENT")
'系统欢迎语
dim SYS_WELCOME
    SYS_WELCOME = "Cmivan <b>S</b>ystem!<br><span>Copyright &copy; cmivan.</span>"
%>
<!--#include file="md5.asp"-->
<!--#include file="function.asp"-->