#!/bin/bash

cmd=$1

home=$(cd $(dirname $0);pwd)
cd ${home}/app
PYTHONPATH="${home}:${PYTHONPATH}"
export PYTHONPATH

PROJECT_NAME="template-tornado"
LOG_DIR=/data/log/${PROJECT_NAME}

if [ ! -n "$2" ] ;then
    env=${ENV}
    if [ ! -n "${env}" ] ;then
        echo "Can not load ${ENV} from system, only (dev, test, pre, prod) is available"
        echo "Usage: `basename $0` cmd(start, stop, restart) env(dev, test, pre, prod, or load \${ENV} from system)"
        exit 1
    fi
else
    env=$2
fi

function get_num()
{
    num=$(ps -ef | grep -w "python main.py --env=${env}" | grep -v grep | wc -l)
    return ${num}
}

function init_env()
{
    pipenv install --deploy
    if ! test -d ${LOG_DIR}; then mkdir -p ${LOG_DIR}; fi
}

function start()
{
    init_env
    get_num
    num=$?
    if [ "${num}" -ge "1" ];then
        echo "${PROJECT_NAME} is running"
        return
    fi
    echo "${PROJECT_NAME} is starting..."
    pipenv run python main.py --env=${env} >> $LOG_DIR/${PROJECT_NAME}.${env}.log 2>&1 &
    sleep 3
    get_num
    num=$?
    if [ "${num}" -ge "1" ];then
        echo "${PROJECT_NAME} is started"
    else
        echo "start ${PROJECT_NAME} failed"
        exit 1
    fi
}

function stop()
{
    echo "${PROJECT_NAME} is stopping..."
    ps -ef | grep "python main.py --env=${env}" | grep -v grep | awk '{print $2}' | xargs kill -9
    sleep 3
    get_num
    num=$?
    if [ "${num}" == "0" ];then
        echo "${PROJECT_NAME} is stopped"
        return 0
    else
        echo "stop ${PROJECT_NAME} failed"
        exit 1
    fi
}

function restart()
{
    stop
    ret=$?
        if [ "${num}" == "0" ];then
            start
            return $?
        else
            exit 1
    fi
}

if [ "$#" -le "2" ];then
    echo "cmd is ${cmd}"
    echo "env is ${env}"
    if [[ "${env}" =~ ^(dev|test|pre|prod)$ ]];then
        "$1"
    else
        echo "env invalid, only (dev, test, pre, prod) is available"
        echo "Usage: `basename $0` cmd(start, stop, restart) env(dev, test, pre, prod)"
        exit 1
    fi
else
    echo "Usage: `basename $0` cmd(start, stop, restart) env(dev, test, pre, prod)"
    echo "You provided $# parameters, but 2 are required."
    exit 1
fi
