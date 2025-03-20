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

String sql = "";

//그래프 데이터를 삭제한다.
sql  = "delete from graph_data ";
sql += "where code = '" + code + "' ";
db.RunCommand(sql);

//종목에 대해서 분석을 요청한다.
sql  = "update stock set state = 'A' ";
sql += "where code = '" + code + "' ";
db.RunCommand(sql);
out.print("종목을 분석을 요청하였습니다.");
db.DBClose();
%>