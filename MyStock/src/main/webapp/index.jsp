<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>
<%
String code = request.getParameter("code");
String predicted_price = request.getParameter("predicted_price");
%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>주가지수 예측</title>
		<link rel="stylesheet" href="./css/stock.css" charset="utf-8">
		<link rel="stylesheet" href="./css/jquery-ui.css">
		<script src="./js/jquery-3.7.1.js"></script>
		<script src="./js/jquery-ui.js"></script>
		<script src="https://code.highcharts.com/stock/highstock.js"></script>		
	</head>
	<body>
		<script>
			window.onload = function()
			{
				ShowTime();
				setInterval(() => ShowTime(), 1000);
				ShowList();
			}
			
			//종목 목록을 표시한다.
			function ShowList()
			{
				$.ajax({
					type : "get",
					url: "stock.jsp",
					dataType: "html",
					success : function(data) 
					{	
						// 통신이 성공적으로 이루어졌을때 이 함수를 타게된다.
						$("#itemList").html(data);
					},
					complete : function(data) 
					{	
						// 통신이 성공하거나 실패했어도 이 함수를 타게된다.
					},
					error : function(xhr, status, error) 
					{
						// 통신 오류 발생시	
					}
				});				
			}
			
			//종목을 추가한다.
			function AddStock()
			{
				if( $("#code").val() == "")
				{
					alert("종목 코드를 입력하세요");
					$("#code").focus();
					return;
				}
				if( $("#name").val() == "")
				{
					alert("종목명을 입력하세요");
					$("#name").focus();
					return;
				}	

				$.ajax({
					type : "post",
					url: "addstock.jsp",
					data :
					{
						code : $("#code").val(),
						name : $("#name").val(),
					},
					dataType: "html",
					success : function(data) 
					{	
						// 통신이 성공적으로 이루어졌을때 이 함수를 타게된다.
						data = data.trim();
						if(data == "ERR01")
						{
							alert("종목 정보를 입력하세요.");	
						}
						if(data == "ERR02")
						{
							alert("동일한 종목 코드가 등록되어 있습니다.");	
						}
						if(data == "OK")
						{
							alert("종목을 등록하였습니다.");
							ShowList();
						}
					},
					complete : function(data) 
					{	
						// 통신이 성공하거나 실패했어도 이 함수를 타게된다.
					},
					error : function(xhr, status, error) 
					{
						// 통신 오류 발생시	
					}
				});				
			}
			
			//종목을 삭제한다.
			function DeleteItem(code)
			{
				if(confirm("종목을 삭제하시겠습니까?") == false)
				{
					return;	
				}	
				$.ajax({
					type : "post",
					url: "delstock.jsp",
					data :
					{
						code : code,
					},
					dataType: "html",
					success : function(data) 
					{	
						// 통신이 성공적으로 이루어졌을때 이 함수를 타게된다.
						data = data.trim();
						alert(data);
						ShowList();
					},
					complete : function(data) 
					{	
						// 통신이 성공하거나 실패했어도 이 함수를 타게된다.
					},
					error : function(xhr, status, error) 
					{
						// 통신 오류 발생시	
					}
				});				
			}
			
			//분석을 요청한다.
			function UpdateState(code)
			{
				$.ajax({
					type : "post",
					url: "updatestock.jsp",
					data :
					{
						code : code,
					},
					dataType: "html",
					success : function(data) 
					{	
						// 통신이 성공적으로 이루어졌을때 이 함수를 타게된다.
						data = data.trim();
						alert(data);
						ShowList();
						GetItemDetail(code);
					},
					complete : function(data) 
					{	
						// 통신이 성공하거나 실패했어도 이 함수를 타게된다.
					},
					error : function(xhr, status, error) 
					{
						// 통신 오류 발생시	
					}
				});				
			}
			
			
			//화면에 시간을 표시한다.
			function ShowTime()
			{
				const date = new Date();
				curTime = date.toLocaleString("ko-kr");
				$("#curTime").html(curTime);
			}
			
			//조회 버튼 클릭
			function GetItemDetail(code)
			{
				$.ajax({
					type : "get",
					url: "detail.jsp?code=" + code,
					dataType: "html",
					success : function(data) 
					{	
						// 통신이 성공적으로 이루어졌을때 이 함수를 타게된다.
						$("#itemDetail").html(data);
					},
					complete : function(data) 
					{	
						// 통신이 성공하거나 실패했어도 이 함수를 타게된다.
					},
					error : function(xhr, status, error) 
					{
						// 통신 오류 발생시	
					}
				});					
			}
		</script>		
		<table border="0" style="width:1050px" align="center">
			<tr>
				<td colspan="2"  style="height:80px" align="center">
					<h2>주가지수 예측</h2> 
				</td>
			</tr>
			<tr>
				<td colspan="2" align="right">현재시간 : <span style="color:#C00000" id="curTime"></span></td>
			</tr>			
			<tr>
				<td width="500px" valign="top" id="itemList">
				이곳에 종목 목록이 표시됩니다.		
				</td>
				<td valign="top" id="itemDetail">
					<table border="0" class="tb" style="width:100%" align="center">
						<tr>
							<td colspan="2" style="height:400px" valign="top">
								<ul>
									<li>- 왼쪽의 목록에서 종목을 선택하면 해당 종목에
										대한 주가지수 예측을 위한 정보가
										<br>&nbsp;&nbsp; 표시됩니다.
									</li>
									<li>- 등록 가능한 주식은 최대 10개까지 입니다.
									</li>									
								</ul> 
							</td>
						</tr>
					</table>		
				</td>
			</tr>
			<%-- <%
			if(code == null || code == "")
			{
				%> --%>
			<!-- 	<tr>	
					<td>
						메롱
					</td>
				</tr> -->
			<%-- 	<% 
			}else
			{
				%> --%>
				<tr>
					<td colspan="2">
						<table style="width:100%; border-collapse:collapse; border:1px solid #cacaca; border-top:2px solid green;" align="center">
							<tr>
								<td><div id="container"></div></td>
							</tr>
						</table><br>		
					</td>
				</tr>
				<%-- <%
			}
			%> --%>
		</table>
		<script>
			//Highcharts 그래프 설정
			function renderChart(data) 
			{
			 console.log("Received data:", data);

			 const knnData = data.filter(d => d.model === 'KNN').map(d => [new Date(d.date).getTime(), d.predictedPrice]);
			 const lrData = data.filter(d => d.model === 'LR').map(d => [new Date(d.date).getTime(), d.predictedPrice]);
			 const olsData = data.filter(d => d.model === 'OLS').map(d => [new Date(d.date).getTime(), d.predictedPrice]);
			 const lstmData = data.filter(d => d.model === 'LSTM').map(d => [new Date(d.date).getTime(), d.predictedPrice]);
			 const gruData = data.filter(d => d.model === 'GRU').map(d => [new Date(d.date).getTime(), d.predictedPrice]);

			 // 실제 주가 데이터는 모든 모델에 대해 공통된 데이터 포인트를 포함함.
			 const realData = data.filter((d, index, self) => 
			     index === self.findIndex(t => t.date === d.date)
			 ).map(d => [new Date(d.date).getTime(), d.actualPrice]);

			 console.log("Filtered KNN Data:", knnData);
			 console.log("Filtered LR Data:", lrData);
			 console.log("Filtered OLS Data:", olsData);
			 console.log("Filtered LSTM Data:", lstmData);
			 console.log("Filtered GRU Data:", gruData);
			 console.log("Real Data:", realData);

			 Highcharts.chart('container', {
			     chart: {
			         type: 'line'
			     },
			     chart: {
			         events: {
			             selection: function(event) {
			                 if(event.xAxis != null)
			                     console.log("selection: ", event.xAxis[0].min, event.xAxis[0].max);
			                 else
			                     console.log("selection: reset");
			             }
			         },
			         zoomType: 'xy'
			     },
			     title: {
			         text: '주가 예측 결과 그래프'
			     },
			     xAxis: {
			         type: 'datetime',
			         title: {
			             text: '날짜'
			         },
			         labels: {
			             formatter: function() {
			                 // Highcharts의 datetime 형식은 숫자로 날짜를 표현합니다. 이를 한국어 날짜 형식으로 변경합니다.
			                 const date = new Date(this.value);
			                 const year = date.getFullYear();
			                 const month = date.getMonth() + 1;
			                 const day = date.getDate();
			                 return year + '년 ' + month + '월 ';
			             }
			         }
			     },
			     yAxis: {
			         title: {
			             text: '주가'
			         },
			         labels: {
			             formatter: function () {
			                 return this.value + ' 원';
			             }
			         }
			     },
			     series: [
			         { name: 'KNN 예측주가', data: knnData },
			         { name: 'LR 예측주가', data: lrData },
			         { name: 'OLS 예측주가', data: olsData },
			         { name: 'LSTM 예측주가', data: lstmData },
			         { name: 'GRU 예측주가', data: gruData },
			         { name: '실제주가', data: realData }
			     ],
			     tooltip: {
			         shared: true,
			         crosshairs: true
			     },
			     plotOptions: {
			         series: {
			             marker: {
			                 enabled: false
			             }
			         }
			     }
			 });
			}
		</script>
	</body>
</html>    