<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>
<%
String code = request.getParameter("code");
DBManager db = new DBManager();
if(code == null) 
{
	System.out.println("code == null"); 
}else 
{
    db.DBOpen();

	//String sql = "select date, actual_price, predicted_price, model from graph_data where code = '005930'";
    String sql = "select date, actual_price, predicted_price, model from graph_data where code = '" + code + "'";
    db.RunSelect(sql);
}

List<Map<String, Object>> graphData = new ArrayList<>();
while (db.GetNext()) 
{
    Map<String, Object> dataPoint = new HashMap<>();
    dataPoint.put("date", db.GetValue("date"));
    dataPoint.put("actualPrice", Float.parseFloat(db.GetValue("actual_price")));
    dataPoint.put("predictedPrice", Float.parseFloat(db.GetValue("predicted_price")));
    dataPoint.put("model", db.GetValue("model"));
    graphData.add(dataPoint);
}

String json = new Gson().toJson(graphData);
db.DBClose();
System.out.println("Graph Data JSON: " + json); // 디버그용 출력
out.print(json);
%>