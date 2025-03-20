import pandas as pd
import numpy as np
from tensorflow import keras
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings("ignore")

# LSTM(Long Short-Term Memory, 장단기 메모리)을 통한 주가 예측 함수
def PredictStock(df, beginVal):
    window_size = 20
    
    # 과거순으로 정렬 (오래된 데이터가 상위에 위치)
    df = df.sort_values(by='날짜', ascending=True).reset_index(drop=True)
    
    # 원래 종가 데이터를 저장
    original_close = df['종가'].copy()
    
    # 날짜 컬럼을 datetime으로 변환하여 오류 방지
    df['날짜'] = pd.to_datetime(df['날짜'])
    
    # 특정 날짜 이후 예측값 출력
    begins = df.index[df['날짜'] == '2023-11-6']
    print(begins)
    
    # 날짜 컬럼을 인덱스로 설정
    df.set_index('날짜', inplace=True)
    
    # 데이터 스케일링 (표준화)
    scaler = StandardScaler()
    scaled_data = scaler.fit_transform(df.iloc[:, 0:5])
    df.iloc[:, 0:5] = scaled_data
    
    # 입력(x) 및 출력(y) 데이터 생성
    x = []
    y = []
    for i in range(len(df) - window_size):
        temp0 = df.iloc[i:i+window_size, 0:5]
        x.append(temp0.values)
        temp1 = df.iloc[i+window_size, 4]  # 종가 컬럼 (4번째)
        y.append(temp1)
        
    x = np.array(x)
    y = np.array(y)
    
    # 훈련 데이터와 테스트 데이터 분할
    split_point = begins[0] - window_size
    x_train = x[:split_point]
    y_train = y[:split_point]
    x_test  = x[split_point:]
    y_test  = y[split_point:]
    
    # 훈련 데이터 8, 테스트 데이터 2로 나눔
    x_train, x_val, y_train, y_val = train_test_split(x_train, y_train, test_size=0.2, shuffle=False)
    
    print(x_train.shape, x_val.shape, x_test.shape)
    print(y_train.shape, y_val.shape, y_test.shape)
    
    # 콜백 설정
    checkpoint_filepath = '/content/model.weights.h5'
    cbk = keras.callbacks.ModelCheckpoint(
        filepath=checkpoint_filepath,
        save_weights_only=True,
        monitor='val_mae',
        mode='auto',
        save_best_only=True)
    
    es = keras.callbacks.EarlyStopping(
        patience=100, 
        restore_best_weights=True)
    
    # 모델 정의
    model = keras.Sequential()
    model.add(keras.layers.LSTM(48, activation='tanh', input_shape=(x_train.shape[1], x_train.shape[2])))
    model.add(keras.layers.Dropout(0.4))
    model.add(keras.layers.Dense(64, activation='relu'))
    model.add(keras.layers.Dropout(0.4))
    model.add(keras.layers.Dense(1))
    
    # 모델 컴파일
    model.compile(loss='mae', optimizer=Adam(0.01), metrics=['mae'])
    
    # 모델 훈련
    history = model.fit(x_train, y_train, epochs=50, callbacks=[cbk, es], validation_data=(x_val, y_val))
    
    # 저장된 최적 가중치 로드
    model.load_weights(checkpoint_filepath)
    
    # 테스트 데이터로 모델 평가
    score = model.evaluate(x_test, y_test, verbose=0)
    print('Test loss:', score[0])
    print('Test accuracy:', score[1])
    
    # 예측값을 스케일링 이전으로 변환
    y_pred = model.predict(x_test)
    y_test_orig = scaler.inverse_transform(np.hstack([np.zeros((len(y_test), 4)), y_test.reshape(-1, 1)]))[:, -1]
    y_pred_orig = scaler.inverse_transform(np.hstack([np.zeros((len(y_pred), 4)), y_pred]))[:, -1]

    # 마지막 날의 예측값과 전일 종가 비교
    last_actual_price = y_test_orig[-2]
    today_predict_price = y_pred_orig[-1]
    
    last_actual_price = original_close.iloc[-2]
    if today_predict_price > last_actual_price:
        prediction_trend = "상승"
    else:
        prediction_trend = "하락"

    # test_data 생성
    test_data = df.iloc[-len(y_test_orig):].copy()
    test_data['예측'] = y_pred_orig.astype(int)  # 예측 종가를 정수로 변환하여 저장

    # 원래 종가 데이터를 사용하여 '종가' 컬럼 설정
    test_data['종가'] = original_close.iloc[-len(test_data):].values  # 실제 종가 데이터를 사용
    
    # 날짜 인덱스를 reset_index를 통해 컬럼으로 변환
    test_data.reset_index(inplace=True)

    return today_predict_price, prediction_trend, test_data
