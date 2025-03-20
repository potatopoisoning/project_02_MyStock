import numpy as np
import pandas as pd
from tensorflow.keras.layers import Dense, GRU, Dropout, BatchNormalization
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from tensorflow.keras import Sequential
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings("ignore")

def PredictStock(df, begin_price):
    # 과거순으로 정렬 (오래된 데이터가 상위에 위치)
    df = df.sort_values(by='날짜', ascending=True).reset_index(drop=True)
    
    # 필요한 열 선택
    df = df.loc[:, ['날짜', '시가', '고가', '저가', '종가', '거래량']]
    df['날짜'] = pd.to_datetime(df['날짜'])
    df.set_index('날짜', inplace=True)

    # 이상치 제거 (Optional)
    df = df[(df['거래량'] > 0) & (df['종가'] > 0)]

    # x, y 분할
    y = df['종가']
    x = df[['시가', '고가', '저가', '종가', '거래량']]

    # 표준화 x값 스케일링
    scaler = StandardScaler()
    scaler_df = scaler.fit_transform(x.values.reshape(-1, 5))
    y = np.array(y)

    # 데이터셋을 시계열 데이터로 만드는 부분을 풀어쓰기
    window_size = 20  # 윈도우 사이즈 정의
    feature_list = []
    label_list = []

    # 데이터의 길이에서 윈도우 사이즈를 뺀 만큼 반복
    for i in range(len(scaler_df) - window_size):
        # 윈도우 크기만큼의 데이터를 슬라이싱하여 feature_list에 추가
        features = scaler_df[i:i + window_size]
        feature_list.append(features)
        # 윈도우 크기 다음의 값을 label_list에 추가 (예측할 값)
        label = y[i + window_size]
        label_list.append(label)

    # 리스트를 numpy 배열로 변환
    x = np.array(feature_list)
    y = np.array(label_list)

    # 데이터셋 분할
    split_point = int(len(x) * 0.8)
    x_train = x[:split_point]  # 학습 데이터
    x_test = x[split_point:]  # 테스트 데이터
    y_train = y[:split_point]  # 학습 데이터에 대한 라벨
    y_test = y[split_point:]  # 테스트 데이터에 대한 라벨

    # 모델 생성 및 학습
    model = Sequential()
    model.add(GRU(50, activation='tanh', return_sequences=True, input_shape=(window_size, 5)))
    model.add(Dropout(0.2))
    model.add(BatchNormalization())
    model.add(GRU(50, activation='tanh'))
    model.add(Dropout(0.2))
    model.add(BatchNormalization())
    model.add(Dense(units=64, activation='relu'))
    model.add(Dropout(0.2))
    model.add(Dense(units=32, activation='relu'))
    model.add(Dense(units=1))
    model.compile(loss='mse', optimizer='adam')
    model.summary()

    # 콜백 설정
    early_stopping = EarlyStopping(patience=10, restore_best_weights=True)
    reduce_lr = ReduceLROnPlateau(factor=0.1, patience=5)

    # 모델 학습
    model.fit(x_train, y_train, epochs=150, batch_size=32, validation_split=0.2, 
              callbacks=[early_stopping, reduce_lr])

    # 예측
    # 최근 20일 데이터를 사용하여 다음 날의 주가를 예측
    recent_data = df.tail(window_size)
    recent_scaled = scaler.transform(recent_data)
    pred = model.predict(recent_scaled.reshape(1, window_size, 5))
    # 예측 종가 소수점 없애고 정수로 변환
    pred = int(pred[0][0])
    print(pred)

    # 전일 종가 대비 예측 종가 비교
    yesterday_close = df['종가'].iloc[-2]
    if pred > yesterday_close:
        trend = '상승'
    else:
        trend = '하락'

    print(f"전일 종가: {yesterday_close}, 예측 종가: {pred}, 트렌드: {trend}")

    # 예측된 주가 시각화용 데이터 생성
    pred_df = pd.DataFrame(model.predict(x), index=df.index[window_size:window_size + len(y)])
    pred_df.index.name = '날짜'
    # 소수점 없애고 정수로 변환
    pred_df['예측'] = pred_df[0].astype(int)

    # x_test에 해당하는 날짜 및 예측값 생성
    test_dates = df.index[split_point + window_size:split_point + window_size + len(y_test)]
    y_test_pred = model.predict(x_test)
    y_test_pred = y_test_pred.astype(int)

    # 테스트 데이터 프레임 생성
    test_data = pd.DataFrame({'날짜': test_dates, '종가': y_test, '예측': y_test_pred.flatten()})

    # 날짜 인덱스를 reset_index를 통해 컬럼으로 변환
    test_data.reset_index(inplace=True)

    # 예측값, 테스트데이터값, 데이터프레임 반환
    return pred, trend, test_data
