<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>    
<%
String code = request.getParameter("code");
if(code == null)
{
	out.print("종목 정보를 입력하세요.");
	return;
}

DBManager db = new DBManager();
db.DBOpen();

//그래프 데이터를 삭제한다.
String sql = "";
sql  = "delete from graph_data ";
sql += "where code = '" + code + "' ";
db.RunCommand(sql);
out.print("그래프 데이터를 삭제하였습니다.");

//종목을 삭제한다.
sql  = "delete from stock ";
sql += "where code = '" + code + "' ";
db.RunCommand(sql);
out.print("종목을 삭제하였습니다.");
db.DBClose();
%>