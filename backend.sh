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

# if [ ! -d "/var/log/expense-logs/" ]
# then
#     mkdir /var/log/expense-logs &>>$LOG_FILE_NAME # Here we can simply use -p than the condition
#     VALIDATE $? "creating expense-logs directory"
# else
#     echo -e "expense_logs directory already created --- $Y SKIPPING $N"
# fi

mkdir -p /var/log/expense-logs &>>$LOG_FILE_NAME # Here we can simply use -p than the condition
VALIDATE $? "creating expense-logs directory"

dnf module disable nodejs -y  &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default Nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nodejs:20"

dnf install nodejs -y   &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding expense user"
else
    echo -e "expense user already exists ... $Y SKIPPING $N"
fi
 
mkdir -p /app  &>>$LOG_FILE_NAME    #-p means it will be created if the directory does not exist. if exists it will simply ignores
VALIDATE $? "creating an app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip   &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend code"

cd /app     # change directory to app
rm -rf /app/* # it removes all the available data in the app directory

unzip /tmp/backend.zip  &>>$LOG_FILE_NAME
VALIDATE $? "Unziping the backend code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Insatlling dependincies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare MySQL schema

dnf install mysql -y    &>>$LOG_FILE_NAME
VALIDATE $? "Insatlling MySQL client"

mysql -h mysql.daws82s.space -uroot -pExpenseApp@1 < /app/schema/backend.sql    &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

systemctl enable backend    &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend"