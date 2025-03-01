#!/bin/bash

USERID=$(id -u)

R="\e[31m"  #Red
G="\e[32m"  #Green
Y="\e[33m"  #Yellow
N="\e[0m"   #Normal

LOGS_FOLDER="/var/log/expense-logs" # have to create like this in linux $ sudo mkdir -p /var/log/expense-logs
LOG_FILE=$(echo $0 | cut -d "." -f1 )   # It wll takes 13-logs.sh file name before .(dot)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){             #We can write the function anywhere in the program
    if [ $1 -ne 0 ]   
    then
        echo -e "$2 ... $R FAILURE $N" #-e means enable, $R color cpplying
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e " $R ERROR:: you must have sudo access to execute this script $N"
        exit 1      #Other than 0
    fi
    }

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

mkdir /var/log/expense-logs
VALIDATE $? "creating expense-logs directory"

dnf module disable nodejs -y
VALIDATE $? "Disabling existing default Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling Nodejs:20"

dnf install nodejs -y
VALIDATE $? "Installing Nodejs"

useradd expense
VALIDATE $? "Adding expense user"

mkdir /app
VALIDATE $? "creating an app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend code"

cd /app     # change directory to app

unzip /tmp/backend.zip
VALIDATE $? "Unziping the backend code"

npm install
VALIDATE $? "Insatlling dependincies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare MySQL schema

dnf install mysql -y
VALIDATE $? "Insatlling MySQL client"

mysql -h mysql.daws82s.space -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Setting up the transaction schema and tables"

systemctl daemon-reload
VALIDATE $? "Daemon Reload"

systemctl enable backend
VALIDATE $? "Enabling backend"

systemctl start backend
VALIDATE $? "Satarting Backend"