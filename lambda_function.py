import boto3
import json
import pandas as pd
from botocore.exceptions import ClientError
import io
import requests

HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}
BOOKS = 'https://gutendex.com/books/'
NUM_PAGES = 80

def fetchJson(url: str, headers: dict) -> dict[str, any]:
  try: 
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()
  except requests.exceptions.RequestException as err: 
    raise err

def get_data(fetch_data, url: str, headers: dict, num_pages: int) -> list:
    data = []
    first_page = fetch_data(url=url, headers=headers)
    data.extend(first_page['results'])
    page_link = first_page['next']

    for i in range(1, num_pages):
        page = fetch_data(url=page_link, headers=headers)
        data.extend(page['results'])
        page_link = page['next']

    df = pd.DataFrame(data)
    
    return df
    
def lambda_handler(event, context):
    s3_client = boto3.client('s3')
    
    try:
        data = get_data(fetchJson, BOOKS, HEADERS, NUM_PAGES)

        clean_df = data[['id','download_count', 'title', 'authors', 'subjects']]

        parquet_buffer = io.BytesIO()
        clean_df.to_parquet(parquet_buffer, index=False, compression='snappy')
        
        bucket_name = 'gutendex'
        folder_name = 'data'
        object_key = f'{folder_name}/data.parquet'
        
        s3_client.put_object(
            Bucket=bucket_name,
            Key=object_key,
            Body=parquet_buffer.getvalue(),
            ContentType='application/vnd.apache.parquet'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps('Data saved successfully')
        }
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"S3 error: {error_code} - {error_message}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Failed to save data to S3: {error_code} - {error_message}')
        }
    except Exception as e:
        print(f'Unexpected error occurred: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps(f'Unexpected error: {str(e)}')
        }
        