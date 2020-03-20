# AWS Lambda Quickstart - JSON w/ pillow

1. Started with Amazon Linux on EC2 instance running t2.micro in us-east-1
2. aws configure (and enter in your credentials)
3. sudo yum update -y
4. sudo su
5. cd /usr/lib64/python2.7/dist-packages/ 
6. rm -rf PIL
7. cd /home/ec2-user
8. sudo yum install gcc bzip2-devel ncurses-devel gdbm-devel xz-devel sqlite-devel openssl-devel tk-devel uuid-devel readline-devel zlib-devel libffi-devel
9. wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
10. tar -xJf Python-3.7.0.tar.xz
11. cd Python-3.7.0
12. ./configure --enable-optimizations
13. make altinstall
14. export PATH=$PATH:/usr/local/bin
15. pip3.7 install pillow
16. mkdir -p /home/ec2-user/lambda_layers/python/lib/python3.7/site-packages
17. cd /usr/local/lib/python3.7/site-packages
18. cp -r PIL /home/ec2-user/lambda_layers/python/lib/python3.7/site-packages
19. cd /home/ec2-user/lambda_layers
20. zip -r pill.zip *
21. aws s3 cp pill.zip s3://<bucket>/pill.zip
22. In the Lambda console, I then created a Lambda Layer using the pill.zip from the s3 bucket and installed it. 
23. I then added the layer to the Python 3.7 Lambda function.
24. I then verified that the following code worked successfully

```
from PIL import Image 
 
def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

```
