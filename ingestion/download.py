import requests as rq

def download(trip_type,year,month):
    url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{trip_type}_tripdata_{year}-{month:02d}.parquet"
    try:    
        response = rq.get(url, timeout= 60,stream=True)

        if response.status_code ==200:
            with open(f"../data/{trip_type}-{year}-{month:02d}.parquet","wb") as file:
                for chunk in response.iter_content(chunk_size=1024):
                    file.write(chunk)
            print(f"Downloaded {trip_type}_{year}_{month:02d}")
        else:
            response.raise_for_status()

    except rq.exceptions.HTTPError as errh:
        print(f"HTTP Error: {errh}")
        raise
    except rq.exceptions.ConnectionError as errc:
        print(f"Error Connecting: {errc}")
        raise
    except rq.exceptions.Timeout as errt:
        print(f"Timeout Error: {errt}")
        raise
    except rq.exceptions.RequestException as err:
        print(f"An unknown error occurred: {err}")
        raise
   


