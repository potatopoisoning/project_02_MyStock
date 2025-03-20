<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="ezen.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*, java.io.*" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.text.DecimalFormat" %>
<%
String code = request.getParameter("code");

DBManager db = new DBManager();
db.DBOpen();

String sql = "";
sql  = "select code,name,state,wdate,cprice,sprice,yprice,eprice,final_trend, ";
sql += "knn_price,knn_trend,lr_price,lr_trend,ols_price,ols_trend, ";
sql += "lstm_price,lstm_trend,gru_price,gru_trend,pdate,msg ";
sql += "from stock ";
sql += "where code = '" + code + "' ";
sql += "order by code ";
db.RunSelect(sql);
if(db.GetNext() == false)
{
	db.DBClose();
	return;
}
String name   = db.GetValue("name");
String state  = db.GetValue("state");
String wdate  = db.GetValue("wdate");
String cprice = db.GetValue("cprice");
String sprice = db.GetValue("sprice");
String yprice = db.GetValue("yprice");
String eprice = db.GetValue("eprice");
String final_trend = db.GetValue("final_trend");
String knn_price = db.GetValue("knn_price");
String knn_trend = db.GetValue("knn_trend");
String lr_price = db.GetValue("lr_price");
String lr_trend = db.GetValue("lr_trend");
String ols_price = db.GetValue("ols_price");
String ols_trend = db.GetValue("ols_trend");
String lstm_price = db.GetValue("lstm_price");
String lstm_trend = db.GetValue("lstm_trend");
String gru_price = db.GetValue("gru_price");
String gru_trend = db.GetValue("gru_trend");
String pdate  = db.GetValue("pdate");
String msg    = db.GetValue("msg");

//DecimalFormat을 사용하여 숫자에 쉼표 추가
DecimalFormat format= new DecimalFormat("#,###");

cprice = format.format(Double.parseDouble(cprice));
sprice = format.format(Double.parseDouble(sprice));
yprice = format.format(Double.parseDouble(yprice));
eprice = format.format(Double.parseDouble(eprice));
knn_price = format.format(Double.parseDouble(knn_price));
lr_price = format.format(Double.parseDouble(lr_price));
ols_price = format.format(Double.parseDouble(ols_price));
lstm_price = format.format(Double.parseDouble(lstm_price));
gru_price = format.format(Double.parseDouble(gru_price));

//String을 double로 변환하여 변동금액 및 변동률 계산
String yprice1 = db.GetValue("yprice").replace(",", ""); // 쉼표 제거
String eprice1 = db.GetValue("eprice").replace(",", ""); // 쉼표 제거
double yprice2 = Double.valueOf(yprice1); 
double eprice2 = Double.valueOf(eprice1); 

// 변동금액 계산
double price_change = eprice2 - yprice2;

// 변동률 계산
double percentage_change = (price_change / yprice2) * 100;

// 상승/하락 여부 확인
String change_symbol = "";
String color = "";
String percentage_symbol = "";

if (price_change > 0) {
    change_symbol = "▲";
    color = "red";
    percentage_symbol = "+";
} else {
    change_symbol = "▼";
    color = "blue";
    percentage_symbol = "-";
}

db.DBClose();
%>
<table border="0" class="tb" style="width:100%" align="center">
	<tr>
		<th colspan="2"><strong><%= name %></strong></td>
	</tr>				
	<tr>
		<th style="width:150px">종목명</th>
		<td class="left"><%= name %> (<%= code %>)
		<input type="hidden" id="item_code" value="<%= code %>"></td>
	</tr>
	<tr>
		<th>분석상태</th>
		<td class="left">
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
	</tr>
	<%
	if(state.equals("C"))
	{
		%>
		<tr>
			<th>오류내용</th>
			<td class="left">
				<%= msg %>	
			</td>
		</tr>		
		<%
	}
	%>
	<%
	if(state.equals("B"))
	{
		%>
		<tr>
			<th>대상일자</th>
			<td class="left"><span id="nowprice"><%= pdate %></span></td>
		</tr>
		<tr>
			<th>전일종가</th>
			<td class="left"><span id="nowprice"><%= yprice %></span> 원</td>
		</tr>	
		<tr>
			<th>당일시가</th>
			<td class="left"><span id="nowprice"><%= sprice %></span> 원</td>
		</tr>
		<tr>
			<th>예측결과</th>
			<td class="left"><span id="nowprice"></span>
				<table border="0" style="width:90%; border-collapse:collapse; " align="center">
					<tr>
						<th>모델명</th>
						<th>결과</th>
						<th>예측가</th>
					</tr>
					<tr>
						<td>KNN</td>
						<td><%= knn_trend %></td>
						<td><%= knn_price %> 원</td>
					</tr>
					<tr>
						<td>LR</td>
						<td><%= lr_trend %></td>
						<td><%= lr_price %> 원</td>
					</tr>
					<tr>
						<td>OLS</td>
						<td><%= ols_trend %></td>
						<td><%= ols_price %> 원</td>
					</tr>
					<tr>
						<td>LSTM</td>
						<td><%= lstm_trend %></td>
						<td><%= lstm_price %> 원</td>
					</tr>
					<tr>
						<td>GRU</td>
						<td><%= gru_trend %></td>
						<td><%= gru_price %> 원</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<th>예측종가</th>
			<td class="left" style="padding-left:5%;"><span id="nowprice"> <%= final_trend %> 예상 / <%= eprice %></span> 원
			&nbsp;&nbsp;전일대비<span style="color: <%= color %>;">
            <%= change_symbol %> <%= String.format("%,.0f", price_change) %> &nbsp;<%= percentage_symbol %><%= String.format("%.2f", Math.abs(percentage_change)) %>%
       		</span>
       		 <span style="color: <%= color %>;">
            
        </span>
			</td>
		</tr>
		<!-- <tr>
			<td colspan="2"><div id="container"></div></td>
		</tr> -->
		<%
	}else
	{
		%>
		<tr>
			<th>대상일자</th>
			<td class="left"><span id="nowprice"><%= pdate %></span></td>
		</tr>
		<tr>
			<th>시가</th>
			<td class="left"><span id="nowprice"><%= sprice %></span> 원</td>
		</tr>	
		<tr>
			<th>예측결과</th>
			<td class="left"><span id="nowprice"></span>
				<table border="0" style="width:90%; border-collapse:collapse; " align="center">
					<tr>
						<th>모델명</th>
						<th>결과</th>
						<th>예측가</th>
					</tr>
					<tr>
						<td>KNN</td>
						<td>-</td>
						<td>-</td>
					</tr>
					<tr>
						<td>LR</td>
						<td>-</td>
						<td>-</td>
					</tr>
					<tr>
						<td>OLS</td>
						<td>-</td>
						<td>-</td>
					</tr>
					<tr>
						<td>LSTM</td>
						<td>-</td>
						<td>-</td>
					</tr>
					<tr>
						<td>GRU</td>
						<td>-</td>
						<td>-</td>
					</tr>
				</table><br>
					<p style="padding-left:5%;">· -</p>
			</td>
		</tr>
		<tr>
			<th>예측종가</th>
			<td class="left" style="padding-left:5%;"><span id="nowprice">-</span> 원</td>
		</tr>
		<%		
	}
	%>		
</table>
<br>
<%-- <script>
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
</script> --%>
<script>
//AJAX 요청을 통해 그래프 데이터 가져오기
$.ajax({
 url: 'getGraphData.jsp',
 type: 'get',
 data: { code: '<%= code %>' },
 dataType: 'json',
 success: function(response) {
     console.log("ajax response:", response);
     renderChart(response);
 },
 error: function(error) {
     console.error('Error fetching data', error);
 }
});
</script> 
<table align="center">	
	<tr>
		<td colspan="2">
			<%
			if(state.equals("B"))
			{
				%>
				<a class="btn sfn" href="javascript:UpdateState('<%= code %>');">예측요청하기</a>
				<%
			}
			%>
			<a class="btn sfnr" href="https://finance.naver.com/item/sise.naver?code=<%= code %>" target="_blank">시세 조회(새창)</a>		
		</td>
	</tr>	
</table>
<br>
<%
db.DBClose();
%>
