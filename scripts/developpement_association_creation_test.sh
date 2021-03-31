#!/bin/sh

request() {
    method=${1}
    url=${2}
    expected_http_status=${3}
    parameters=${4}
    if [ -z "${parameters}" ]
    then
        echo "curl -X ${method} -o /dev/null -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}"
        http_status=`curl -X ${method} -o /dev/null -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}`
    else
        echo "curl -X ${method} -d '${parameters}' -o /dev/null -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}"
        http_status=`curl -X ${method} -d ${parameters} -o /dev/null -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}`
    fi
    if [ ${http_status} != ${expected_http_status} ]
    then
        echo "${method} ${url} ${parameters} ${http_status} while expecting ${expected_http_status}"
        exit 1
    fi
}

get() {
    request GET ${1} ${2} ${3}
}

post() {
    request POST ${1} ${2} "${3}"
}

put() {
    request PUT ${1} ${2} "${3}"
}

delete() {
    request DELETE ${1} ${2} ${3}
}

post http://localhost:3000/users 201 "firstname=John&lastname=Doe&age=23"
post http://localhost:3000/users 201 "firstname=Janette&lastname=Doe&age=32"

post http://localhost:3000/association-forms 201
put http://localhost:3000/legal-service/validate 200 "associationFormId=1"
put http://localhost:3000/financial-service/validate 200 "associationFormId=1"
post http://localhost:3000/verbal-processes 201 "idVoters[]=1&idVoters[]=2&content=ContentOfVerbalProcess&date=01/01/2021"
post http://localhost:3000/associations 201 "name=Assoc1&idUsers[]=1&idUsers[]=2&roles[]=Treasurer&roles[]=President&associationFormId=1&verbalProcessId=1"

get http://localhost:3000/associations/Assoc1 200