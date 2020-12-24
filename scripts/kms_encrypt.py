import os
import sys
import boto3
import base64

os.environ['AWS_DEFAULT_REGION'] = 'ap-northeast-1'
client = boto3.client('kms')
keyId = sys.argv[1]
password = sys.argv[2]

response = client.encrypt(
    KeyId=keyId,
    Plaintext=password.encode(),
)['CiphertextBlob']

print(base64.b64encode(response).decode('utf-8'))
