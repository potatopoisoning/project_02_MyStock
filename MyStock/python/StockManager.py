from DBManager import DBManager
import pandas as pd
import datetime as dt
import time
import naver_crawling as nc  
from collections import Counter
import warnings
warnings.filterwarnings("ignore")

# 각 알고리즘 임포트
import knn
import lr
import ols
import lstm
import gru

# CSV 읽는 함수
def ReadCSV(code):
    try:
        filename = code + ".csv"
        df = pd.read_csv(filename, encoding="euc-kr")
    except FileNotFoundError:
        return None, False

    df['날짜'] = pd.to_datetime(df['날짜'])
    return df, True

# 주식 예측 및 데이터베이스 업데이트 함수
def RunStock():
    db1 = DBManager()
    db2 = DBManager()
    if not db1.DBOpen("192.168.0.92", "MyStock", "root", "1234"):
        return False
    db2.DBOpen("192.168.0.92", "MyStock", "root", "1234")

    sql = "SELECT code, name FROM stock WHERE state = 'A'"
    if not db1.OpenQuery(sql):
        db1.DBClose()
        return False
    
    total = db1.GetTotal()
    for row in range(total):
        code = db1.GetValue(row, "code")
        name = db1.GetValue(row, "name")
        print(f"[{name}]에 대해서 분석을 수행합니다.")
        
        df = nc.GetURL(code)
        if df.empty:
            print("해당 종목의 주가 정보를 수집할 수 없습니다.")
            sql = f"UPDATE stock SET state = 'C', msg = '해당 종목의 주가 정보를 수집할 수 없습니다.' WHERE code = '{code}'"
            db2.RunSQL(sql)
            continue
        
        df, flag = ReadCSV(code)
        if not flag:
            print("해당 종목의 주가 정보를 수집할 수 없습니다.")
            sql = f"UPDATE stock SET state = 'C', msg = '해당 종목의 주가 정보를 수집할 수 없습니다.' WHERE code = '{code}'"
            db2.RunSQL(sql)
            continue
        
        # 오늘의 시가를 얻는다.
        df = df.sort_values(by='날짜', ascending=False).reset_index(drop=True)
        pdate = str(df.loc[0]["날짜"])[:10]
        sprice = int(df.loc[0]["시가"])
        cprice = int(df.loc[0]["종가"])  # 당일 csv파일의 종가를 현재 가격으로 설정
        yprice = int(df.loc[1]["종가"])
        print(f"대상일자: {pdate}")
        print(f"시작가격: {sprice}")
        print(f"현재가격: {cprice}")
        
        cutdate = dt.datetime(2021, 6, 1)
        df = df[df["날짜"] > cutdate]
        df = df.dropna()

        try:
            knn_price, knn_trend, knn_test_data = knn.PredictStock(df, sprice)
            lr_price, lr_trend, lr_test_data = lr.PredictStock(df, sprice)
            ols_price, ols_trend, ols_test_data = ols.PredictStock(df, sprice)
            lstm_price, lstm_trend, lstm_test_data = lstm.PredictStock(df, sprice)
            gru_price, gru_trend, gru_test_data = gru.PredictStock(df, sprice)
            
            print(f"knn 예측 종가: {knn_price}, knn 트렌드: {knn_trend}")
            print(f"lr 예측 종가: {lr_price}, lr 트렌드: {lr_trend}")
            print(f"ols 예측 종가: {ols_price}, ols 트렌드: {ols_trend}")
            print(f"lstm 예측 종가: {lstm_price}, lstm 트렌드: {lstm_trend}")
            print(f"gru 예측 종가: {gru_price}, gru 트렌드: {gru_trend}")

            predictions = [knn_trend, lr_trend, ols_trend, lstm_trend, gru_trend]
            prices = [knn_price, lr_price, ols_price, lstm_price, gru_price]

            # 트렌드 카운트
            trend_counter = Counter(predictions)

            # 가장 많이 발생한 트렌드를 final_trend로 설정
            final_trend = trend_counter.most_common(1)[0][0]
            
            # 최종 가격 계산
            if final_trend == "상승":
                filtered_prices = [price for trend, price in zip(predictions, prices) if trend == "상승"]
            elif final_trend == "하락":
                filtered_prices = [price for trend, price in zip(predictions, prices) if trend == "하락"]
            else:
                filtered_prices = [price for trend, price in zip(predictions, prices) if trend == "보합"]
            
            final_price = sum(filtered_prices) / len(filtered_prices) if filtered_prices else 0

            final_trend = "상승" if predictions.count("상승") >= 3 else "하락"

            print("최종 예측 결과:", final_trend)
            print("최종 예측 가격:", final_price)

            sql = f"""
            update stock set 
               state = 'B', 
               pdate = '{pdate}', 
               cprice = {cprice},
               sprice = {sprice},
               yprice = {yprice},
               knn_price = {knn_price},
               knn_trend = '{knn_trend}',
               lr_price = {lr_price},
               lr_trend = '{lr_trend}',
               ols_price = {ols_price},
               ols_trend = '{ols_trend}',
               lstm_price = {lstm_price},
               lstm_trend = '{lstm_trend}',
               gru_price = {gru_price},
               gru_trend = '{gru_trend}',
               eprice = {final_price},
               final_trend = '{final_trend}',            
               msg = NULL
            where code = '{code}'
            """
            print(sql)
            db2.RunSQL(sql)

            test_data_list = [(knn_test_data, 'KNN'), (lr_test_data, 'LR'), (ols_test_data, 'OLS'), (lstm_test_data, 'LSTM'), (gru_test_data, 'GRU')]
            for test_data, model in test_data_list:
                for index, row in test_data.iterrows():
                    sql = f"""
                    INSERT INTO graph_data (code, date, actual_price, predicted_price, model)
                    VALUES ('{code}', '{row['날짜']}', {row['종가']}, {row['예측']}, '{model}')
                    """
                    db2.RunSQL(sql)
            
        except Exception as e:
            print(f"예측 중 오류 발생: {e}")
            sql = f"UPDATE stock SET state = 'C', msg = '예측 중 오류 발생: {str(e)}' WHERE code = '{code}'"
            db2.RunSQL(sql)

    db1.DBClose()
    db2.DBClose()
    return True

while True:
    print("====> 주가 예측 작업을 수행합니다.")
    if not RunStock():
        print("DB 연결에 실패하였습니다.")
        break
    print("====> 주가 예측 작업을 완료합니다.")
    time.sleep(5)
