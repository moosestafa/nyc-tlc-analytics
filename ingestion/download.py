import requests as rq

def download(trip_type,year,month):
    url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{trip_type}_tripdata_{year}-{month}.parquet"
    try:    
        response = rq.get(url, timeout= 60,stream=True)

        if response.status_code ==200:
            with open(f"{trip_type}-{year}-{month}.parquet","wb") as file:
                for chunk in response.iter_content(chunk_size=1024):
                    file.write(chunk)
            print(f"Downloaded {trip_type}_{year}_{month}")

    except rq.exceptions.HTTPError as errh:
        print(f"HTTP Error: {errh}")
    except rq.exceptions.ConnectionError as errc:
        print(f"Error Connecting: {errc}")
    except rq.exceptions.Timeout as errt:
        print(f"Timeout Error: {errt}")
    except rq.exceptions.RequestException as err:
        print(f"An unknown error occurred: {err}")
   

download("yellow","2015","01")
