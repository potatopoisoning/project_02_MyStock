create database MyStock;

use MyStock;

drop table stock;
drop table graph_data;

create table stock
(
	code varchar(10) not null primary key comment '종목코드',
    name varchar(100) comment '종목명',
    state varchar(2) default 'A' comment '처리상태',
    wdate datetime default now() comment '대상일자',
    cprice int default 0 comment '현재가격',
    yprice int default 0 comment '전날종가',
    sprice int default 0 comment '시작가격',
    eprice int default 0 comment '최종 예측가격',
	final_trend varchar(10) comment '최종 예측 트렌드',
    knn_price int default 0 comment 'KNN 예측가격',
    knn_trend varchar(10) comment 'KNN 트렌드',
    lr_price int default 0 comment 'LR 예측가격',
    lr_trend varchar(10) comment 'LR 트렌드',
    ols_price int default 0 comment 'OLS 예측가격',
    ols_trend varchar(10) comment 'OLS 트렌드',
    lstm_price int default 0 comment 'LSTM 예측가격',
    lstm_trend varchar(10) comment 'LSTM 트렌드',
    gru_price int default 0 comment 'GRU 예측가격',
    gru_trend varchar(10) comment 'GRU 트렌드',
    pdate datetime default now() comment '예측일자',
    msg text comment '오류메시지'
);

create table graph_data 
(
    id int auto_increment primary key,
    code varchar(10),
    date date,
    actual_price float,
    predicted_price float,
    model varchar(10),
    foreign key (code) references stock(code)
);

select * from stock;

