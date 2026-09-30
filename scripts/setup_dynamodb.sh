#!/usr/bin/env bash

set -e

export AWS_REGION=eu-west-2
export AWS_ENDPOINT_URL=http://dynamodb-local:8000
export AWS_ACCESS_KEY_ID=dummy
export AWS_SECRET_ACCESS_KEY=dummy

echo "creating dynamodb tables"

if aws dynamodb describe-table --table-name user_credentials --output off 2>/dev/null; then
  aws dynamodb delete-table \
    --output off \
    --table-name user_credentials \
    || true
fi

aws dynamodb create-table \
  --output off \
  --table-name user_credentials \
  --attribute-definitions \
    AttributeName=UserId,AttributeType=S \
    AttributeName=BearerToken,AttributeType=S \
  --global-secondary-indexes '[
    {
      "IndexName": "BearerTokenIndex",
      "KeySchema": [
        {
          "AttributeName": "BearerToken",
          "KeyType": "HASH"
        }
      ],
      "Projection": {
        "ProjectionType": "KEYS_ONLY"
      },
      "ProvisionedThroughput": {
        "ReadCapacityUnits": 20,
        "WriteCapacityUnits": 20
      }
    }
    ]' \
  --key-schema \
    AttributeName=UserId,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20

aws dynamodb put-item \
  --table-name user_credentials \
  --item '
{
  "OneLoginSub": {
    "S": "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw="
  },
  "OptOut": {
    "BOOL": true
  },
  "BearerToken": {
    "S": "hqhNzxZCu6wwBMY9Kte98I"
  },
  "UserId": {
    "S": "fc7fad8e-9920-4616-aac2-c26ec3ae5568"
  },
  "EmailAddress": {
    "S": "a21zLTQ0Mzc="
  },
  "CreatedAt": {
    "S": "2026-09-30 08:45:02 +0000"
  }
}'

if aws dynamodb describe-table --table-name user_credentials_v2 --output off 2>/dev/null; then
  aws dynamodb delete-table \
    --output off \
    --table-name user_credentials_v2 \
    || true
fi

aws dynamodb create-table \
  --output off \
  --table-name user_credentials_v2 \
  --attribute-definitions \
    AttributeName=UserId,AttributeType=S \
    AttributeName=Type,AttributeType=S \
  --key-schema \
    AttributeName=UserId,KeyType=HASH \
    AttributeName=Type,KeyType=RANGE \
  --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20

aws dynamodb put-item \
  --table-name user_credentials_v2 \
  --item '
{
  "Attributes": {
    "M": {
      "OptOut": {
        "BOOL": false
      },
      "EmailAddress": {
        "S": "a21zLTQ0Mzc="
      },
      "CreatedAt": {
        "S": "2026-09-30 08:45:02 +0000"
      }
    }
  },
  "OneLoginSub": {
    "S": "urn:fdc:gov.uk:2022:56P4CMsGh_02YOlWpd8PAOI-2sVlB2nsNU7mcLZYhYw="
  },
  "Type": {
    "S": "PROFILE"
  },
  "UserId": {
    "S": "fc7fad8e-9920-4616-aac2-c26ec3ae5568"
  }
}'

aws dynamodb put-item \
  --table-name user_credentials_v2 \
  --item '
{
  "Attributes": {
    "M": {
      "CreatedAt": {
        "S": "2026-09-30 08:45:02 +0000"
      }
    }
  },
  "Type": {
    "S": "TOKEN#hqhNzxZCu6wwBMY9Kte98I"
  },
  "BearerToken": {
    "S": "hqhNzxZCu6wwBMY9Kte98I"
  },
  "UserId": {
    "S": "fc7fad8e-9920-4616-aac2-c26ec3ae5568"
  }
}'
