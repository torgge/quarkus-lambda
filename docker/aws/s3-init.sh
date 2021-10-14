set -x
awslocal s3 mb s3://lfc-resource
awslocal sqs create-queue --queue-name local-queue
awslocal sns create-topic --name local-topic
awslocal sns subscribe --notification-endpoint http://localhost:4566/000000000/local-queue --topic-arn arn:aws:sns:us-east-1:000000000000:local-topic --protocol sqs
cd /localstack-config || exit
awslocal s3api put-bucket-notification-configuration --bucket lfc-resource --notification-configuration file://notification.json
awslocal iam create-user --user-name test
awslocal iam create-access-key --user-name test
awslocal iam create-policy --policy-name lambda-role --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:*","Resource":"*"}]}'
awslocal iam attach-user-policy --user-name test --policy-arn arn:aws:iam::000000000000:policy/lambda-role
set +x
