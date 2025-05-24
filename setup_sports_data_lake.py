import boto3
import json
import requests
import os

# AWS configurations
region = os.getenv("AWS_REGION", "us-east-1")
bucket_name = os.getenv("S3_BUCKET_NAME")
glue_database_name = os.getenv("GLUE_DB_NAME")
athena_output_location = f"s3://{bucket_name}/athena-results/"

# Sportsdata.io configurations
api_key = os.getenv("SPORTS_DATA_API_KEY")
nba_endpoint = os.getenv("NBA_ENDPOINT")

# AWS clients
s3_client = boto3.client("s3", region_name=region)
glue_client = boto3.client("glue", region_name=region)
athena_client = boto3.client("athena", region_name=region)


def fetch_nba_data():
    print("Fetching NBA data from SportsDataIO API...")
    try:
        headers = {"Ocp-Apim-Subscription-Key": api_key}
        response = requests.get(nba_endpoint, headers=headers)
        response.raise_for_status()
        data = response.json()
        print(f"Fetched {len(data)} player records.")
        return data
    except Exception as e:
        print(f"Error fetching NBA data: {e}")
        return []


def convert_to_line_delimited_json(data):
    print("Converting data to line-delimited JSON format...")
    return "\n".join([json.dumps(record) for record in data])


def upload_data_to_s3(data):
    print(f"Uploading data to S3 at 'nba/raw-data/'...")
    try:
        line_delimited_data = convert_to_line_delimited_json(data)
        file_key = "nba/raw-data/nba_player_data.jsonl"

        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_key,
            Body=line_delimited_data
        )
        print(f"Upload to S3 successful: {file_key}")
    except Exception as e:
        print(f"Error uploading data to S3: {e}")


def create_glue_table():
    print("Creating AWS Glue table...")
    try:
        glue_client.create_table(
            DatabaseName=glue_database_name,
            TableInput={
                "Name": "nba_players",
                "StorageDescriptor": {
                    "Columns": [
                        {"Name": "PlayerID", "Type": "int"},
                        {"Name": "FirstName", "Type": "string"},
                        {"Name": "LastName", "Type": "string"},
                        {"Name": "Team", "Type": "string"},
                        {"Name": "Position", "Type": "string"},
                        {"Name": "Points", "Type": "int"}
                    ],
                    "Location": f"s3://{bucket_name}/nba/raw-data/",
                    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
                    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
                    "SerdeInfo": {
                        "SerializationLibrary": "org.openx.data.jsonserde.JsonSerDe"
                    },
                },
                "TableType": "EXTERNAL_TABLE",
            },
        )
        print("Glue table created: nba_players")
    except Exception as e:
        print(f"Error creating Glue table: {e}")


def configure_athena():
    print("Setting Athena output configuration...")
    try:
        athena_client.start_query_execution(
            QueryString="CREATE DATABASE IF NOT EXISTS nba_analytics",
            QueryExecutionContext={"Database": glue_database_name},
            ResultConfiguration={"OutputLocation": athena_output_location},
        )
        print("Athena database 'nba_analytics' configured.")
    except Exception as e:
        print(f"Error configuring Athena: {e}")


def main():
    print("Starting NBA Data Lake setup.")
    nba_data = fetch_nba_data()

    if nba_data:
        upload_data_to_s3(nba_data)
    else:
        print("No data fetched. Skipping upload.")

    create_glue_table()
    configure_athena()
    print("NBA Data Lake setup complete.")


if __name__ == "__main__":
    main()
