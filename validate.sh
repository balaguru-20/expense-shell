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

expense_logs=find /var/log/expense-logs/ -type d -name "expense-logs"   &>>$LOG_FILE_NAME

if [ "$expense_logs" -ne 0 ]
then
    mkdir /var/log/expense-logs
    VALIDATE $? "creating expense-logs directory"
else
    echo -e "$expense_logs already created --- $Y SKIPPING $N"
fi