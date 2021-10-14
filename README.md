## QUARKUS AWS LAMBDA - LOCALSTACK


### Aws cli
> Install from Homebrew [Installing the AWS SAM CLI on macOS](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-mac.html)

### Localstack
> The docker image to deploy this application
> located on ./docker/docker-compose.yml
#### We need to run
```
docker-compose up
```
- On docker container starts

  - This is generated an ARN code. This code is used to communicate with the application lambda.
  - We need to add this code ARN into our evironment variable: LAMBDA_ROLE_ARN
> an example: LAMBDA_ROLE_ARN="arn:aws:iam::000000000000:policy/lambda-role"

## Deploy
###first we need to deploy this app
```
./gradlew clean package
```
#ATENTION!
>We have to modify the file target/manage.sh generated on deploy, to call the localstack server, add in command a localendpoint

```
function cmd_create() {
  echo Creating function
  set -x
  aws lambda create-function \
    --endpoint-url=http://localhost:4566 \ <------------------------This command-------------||
    --function-name ${FUNCTION_NAME} \
    --zip-file ${ZIP_FILE} \
    --handler ${HANDLER} \
    --runtime ${RUNTIME} \
    --role ${LAMBDA_ROLE_ARN} \
    --timeout 15 \
    --memory-size 256 \
    ${LAMBDA_META}
# Enable and move this param above ${LAMBDA_META}, if using AWS X-Ray
#    --tracing-config Mode=Active \
}
```

```
function cmd_invoke() {
  echo Invoking function

  inputFormat=""
  if [ $(aws --version | awk '{print substr($1,9)}' | cut -c1-1) -ge 2 ]; then inputFormat="--cli-binary-format raw-in-base64-out"; fi

  set -x

  aws lambda invoke response.txt \
    ${inputFormat} \
    --endpoint-url=http://localhost:4566 \ <------------------------This command-------------||
    --function-name ${FUNCTION_NAME} \
    --payload file://payload.json \
    --log-type Tail \
    --query 'LogResult' \
    --output text |  base64 --decode
  { set +x; } 2>/dev/null
  cat response.txt && rm -f response.txt
}
```

>After the deploy, is generated a ./target folder inside it we have a manage.sh to facilitade our deploy
###run the command to deploy the application
```
sh target/manage.sh create
```
###After the command, We can check the funcion name on server, using the command below
```
aws lambda --endpoint http://localhost:4566 get-function --function-name QuarkusAwsLambda
```
###To test our function we can run the command:
```
 sh target/manage.sh invoke  
```
##References
- [amazon-lambda](https://quarkus.io/guides/amazon-lambda)
- [Integração do AWS Lambda com o Quarkus](https://aws.amazon.com/pt/blogs/aws-brasil/integracao-do-aws-lambda-com-o-quarkus/)
- [Useful tools for local development with AWS services](https://www.luminis.eu/blog/useful-tools-for-local-development-with-aws-services/)
- [Using Lambda with the AWS CLI](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html)
- [Installing the AWS SAM CLI on macOS](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-mac.html)
