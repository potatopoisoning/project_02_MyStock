<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>    
<%
String code = request.getParameter("code");
String name = request.getParameter("name");
if(code == null || name == null)
{
	out.print("ERR01"); //종목 정보를 입력하세요.
	return;
}

DBManager db = new DBManager();
db.DBOpen();

String sql = "";
//같은 종목코드가 등록되어 있는지 검사한다.
sql += "select code ";
sql += "from stock ";
sql += "where code = '" + code + "' ";
db.RunSelect(sql);
if(db.GetNext() == true)
{
	out.print("ERR02"); //동일한 종목 코드가 등록되어 있습니다.
	db.DBClose();
	return;	
}

//종목을 등록한다.
sql  = "insert into stock ";
sql += "(code,name) ";
sql += "values (";
sql += "'" + code + "', ";
sql += "'" + name + "' ";
sql += ") ";
db.RunCommand(sql);
out.print("OK");
db.DBClose();
%>