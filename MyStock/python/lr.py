import pandas as pd
from sklearn.linear_model import LinearRegression
import numpy as np
import warnings
warnings.filterwarnings("ignore")

#lr(Linear Regression, 선형회귀분석)을 통한 주가 예측 함수
def PredictStock(df,beginVal) :
    # 최신순으로 정렬 (최신 데이터가 상위에 위치)
    df = df.sort_values(by='날짜', ascending=False).reset_index(drop=True)
    
    # 상위 80%를 훈련데이터로 설정한다.
    maxrow = df["시가"].count() 
    baserow = maxrow - int(maxrow * 0.8) #baserow는 전체 행 개수의 20% 위치에 해당함
    
    # 훈련 데이터 얻기 (과거데이터)
    train_data = df.iloc[baserow:][["시가", "종가", "날짜"]]
    
    # 테스트 데이터 얻기 (최신데이터)
    test_data = df.iloc[0:baserow][["시가", "종가", "날짜"]]
    
    # 단순회귀분석 모형 객체 생성
    lr = LinearRegression()
    
    # 독립 변수 X
    x = train_data[["시가"]]
    
    # 종속 변수 Y
    y = train_data["종가"]
    
    # 훈련데이터로 모형 학습
    lr.fit(x, y)
    
    # 모형에 테스트 데이터를 입력하여 예측한 값 y_predict 를 얻는다.
    p = test_data[["시가"]]
    y_predict = lr.predict(p)
    
    # 시리즈로 변환
    y_predict = pd.Series(y_predict)
    test_data["예측"] = y_predict
    
    # NA나 inf 값을 0으로 대체한 후 int64로 변환
    # test_data["예측"] 열에서 무한대(np.inf), 음의 무한대(-np.inf), 그리고 결측값(np.nan)을 모두 0으로 대체
    test_data["예측"].replace([np.inf, -np.inf, np.nan], 0, inplace=True)
    
    try:
        test_data["예측"] = test_data["예측"].astype("int64")
    except ValueError as e:
        print("변환 오류:", e)
        test_data["예측"] = test_data["예측"].fillna(0).astype("int64")

    #오늘의 시가를 이용하여 예측한다.
    y_predict = lr.predict([[beginVal]])
    
    # 예측 결과 상승/하락 여부 표시
    last_actual_price = df["종가"].iloc[1]
    print(f"전일 종가: {last_actual_price}")  # 디버그 출력 추가
    if y_predict[0] > last_actual_price:
        prediction_trend = "상승"
    else:
        prediction_trend = "하락"
       
    # 디버그 출력
    print(f"lr 예측 종가: {y_predict[0]}, 예측 트렌드: {prediction_trend}")        
       
    #예측된 자료를 리턴한다.
    return y_predict[0], prediction_trend,test_data

