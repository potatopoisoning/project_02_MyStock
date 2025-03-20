import requests
import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime
import warnings
warnings.filterwarnings("ignore")

# 네이버 시세 웹크롤링하기(지정한 날짜부터 가장 최근날짜까지)
# 네이버 마지막 페이지 번호를 가져오는 함수
def get_last_page(code):
    url = f"https://finance.naver.com/item/sise_day.naver?code={code}&page=1"
    agent_head = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    response = requests.get(url, headers=agent_head)
    soup = BeautifulSoup(response.text, "html.parser")
    navi = soup.find("td", class_="pgRR")
    last_page = int(navi.a["href"].split('=')[-1])
    return last_page

# 네이버 종목 코드와 페이지를 사용하여 웹크롤링 후 전처리하는 함수
# code와 page를 사용하여 네이버 금융 사이트의 특정 주식 종목 페이지의 URL을 생성
def get_stock_data(code, page):
    url = f"https://finance.naver.com/item/sise_day.naver?code={code}&page={page}"
    agent_head = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    response = requests.get(url, headers=agent_head)
    soup = BeautifulSoup(response.text, "html.parser")
    table = soup.find("table", class_="type2")
    df = pd.read_html(str(table))[0]
    df = df.dropna(subset=['날짜'])  # '날짜' 열이 비어있는 행 제거

    # 전일비 데이터 전처리
    df['전일비'] = df['전일비'].str.replace('보합', '')
    df['전일비'] = df['전일비'].str.replace('상승', '')
    df['전일비'] = df['전일비'].str.replace('하락', '-')
    df['전일비'] = df['전일비'].str.replace('상한가', '')
    df['전일비'] = df['전일비'].str.replace('하한가', '')
    df['전일비'] = df['전일비'].str.replace(' ', '')
    df['전일비'] = df['전일비'].str.replace(',', '')
    df['전일비'] = df['전일비'].astype('float64')

    # 날짜 데이터 타입 변환
    df['날짜'] = pd.to_datetime(df['날짜'], format='%Y.%m.%d')
    
    return df

# 주어진 기간 동안의 데이터만 필터링하는 함수
def filter_by_date(df, start_date, end_date):
    mask = (df['날짜'] >= start_date) & (df['날짜'] <= end_date)
    return df.loc[mask]

# 데이터프레임을 CSV 파일로 저장하는 함수
def save_to_csv(df, filename):
    df.to_csv(filename, encoding="euc-kr", index=False)
    print(f"{filename} 파일로 저장되었습니다.")

# 전체 크롤링 과정을 수행하는 함수
def GetURL(code):
    filename = code + ".csv"
    today = datetime.now().strftime("%Y-%m-%d")

    # CSV 파일이 이미 존재하는지 확인
    try:
        existing_data = pd.read_csv(filename, encoding="euc-kr")
        existing_data['날짜'] = pd.to_datetime(existing_data['날짜'])  # 날짜 열을 datetime 형식으로 변환
        print(f"{filename}에서 기존 데이터를 로드했습니다.")
        
        # 오늘 날짜의 데이터가 있는지 확인
        if today in existing_data['날짜'].dt.strftime("%Y-%m-%d").values:
            print(f"{today}의 데이터가 이미 존재합니다.")
            return existing_data
        else:
            print(f"{today}의 데이터가 존재하지 않습니다. 웹 크롤링을 시작합니다...")
    except FileNotFoundError:
        print(f"{filename} 파일을 찾을 수 없습니다. 웹 크롤링을 시작합니다...")
        existing_data = pd.DataFrame(columns=['날짜'])  # 데이터가 없으면 빈 DataFrame 생성

    last_page = get_last_page(code)
    print(f"끝페이지: {last_page}")

    start_date = datetime(2021, 6, 1)
    end_date = datetime.now()

    if not existing_data.empty:
        missing_dates = pd.date_range(start=existing_data['날짜'].max() + pd.Timedelta(days=1), end=end_date).strftime("%Y-%m-%d")
    else:
        missing_dates = pd.date_range(start=start_date, end=end_date).strftime("%Y-%m-%d")

    all_data = pd.DataFrame()
    for page in range(1, last_page + 1):
        print(f"페이지 {page} 크롤링 중...")
        page_data = get_stock_data(code, page)
        
        # 필요한 날짜 범위에 따라 데이터 필터링
        page_data['날짜'] = pd.to_datetime(page_data['날짜'])  # 날짜 열을 datetime 형식으로 변환
        page_data = page_data[page_data['날짜'].dt.strftime("%Y-%m-%d").isin(missing_dates)]
        
        if page_data.empty:
            print("필터링된 데이터가 없으므로 크롤링을 중단합니다.")
            break

        all_data = pd.concat([all_data, page_data])
        
        last_date = page_data['날짜'].min()
        print(f"수집된 데이터의 마지막 날짜: {last_date}")
        
        if last_date < start_date:
            print("수집된 데이터의 마지막 날짜가 시작 날짜보다 이전이므로 크롤링을 중단합니다.")
            break

    # 기존 데이터와 새로 수집된 데이터를 병합
    if not existing_data.empty:
        all_data = pd.concat([existing_data, all_data])
        all_data = all_data.drop_duplicates(subset=['날짜']).sort_values(by='날짜', ascending=True).reset_index(drop=True)
    else:
        all_data = all_data.sort_values(by='날짜', ascending=True).reset_index(drop=True)

    save_to_csv(all_data, filename=filename)
    return all_data


