<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>
<%
DBManager db = new DBManager();
db.DBOpen();
%>    
<table border="0" class="tb edit" style="width:100%" align="center">
	<tbody id="stocklist">
		<tr>		
			<td class="right" colspan="4">
				<div style="display:flex">
					<div style="float: left; flex:1; text-align:left">
						<input id="code" type="text" style="width:160px" placeholder="종목코드">
						<input id="name" type="text" style="width:160px" placeholder="종목명">
					</div>
					<div style="float: right">
						<a href="javascript:AddStock();" class="btn sfn">종목추가</a>
						<a href="javascript:ShowList();" class="btn sfnp">새로고침</a>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<th style="width:80px">종목코드</th>
			<th>종목명</th>						
			<th style="width:80px">상태</th>
			<th style="width:140px">처리</th>
		</tr>
		<%
		int mTotal = 0;
		String sql = "";
		sql  = "select code,name,state ";
		sql += "from stock ";
		sql += "order by code ";
		db.RunSelect(sql);		
		while(db.GetNext() == true)
		{
			mTotal++;
			String code  = db.GetValue("code");
			String name  = db.GetValue("name");
			String state = db.GetValue("state");
			%>
			<tr>
				<td><%= code %></td>
				<td class="left"><%= name %></td>
				<td>
					<%
					switch(state)
					{
					case "A":
						%><span class="status_ableg">분&nbsp;&nbsp;석&nbsp;&nbsp;중</span><%
						break;
					case "B":
						%><span class="status_ableb">분석완료</span><%
						break;
					case "C":
						%><span class="status_re">분석오류</span><%
						break;
					}
					%>					
				</td>
				<td>
					<a class="btn tbin tfc" href="javascript:GetItemDetail('<%= code %>');">조회</a>
					<a class="btn tbin tfg" href="javascript:DeleteItem('<%= code %>');">삭제</a>
				</td>							
			</tr>
			<%
		}
		if(mTotal == 0)
		{
			%>
			<tr>
				<td style="height:310px;" colspan="4">조회된 종목이 없습니다. 종목을 추가하세요.</td>							
			</tr>
			<%
		}
		%>																					
	</tbody>	
</table>	
<%
db.DBClose();
%>