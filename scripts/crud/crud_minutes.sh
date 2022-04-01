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
    request PUT ${1} ${2} ${3}
}

delete() {
    request DELETE ${1} ${2} ${3}
}

post http://localhost:3000/users 201 "firstname=John&lastname=Doe&age=23"
post http://localhost:3000/users 201 "firstname=Janette&lastname=Doe&age=32"
post http://localhost:3000/associations 201 "idUsers[]=1&idUsers[]=2&name=Assoc1"
post http://localhost:3000/roles 201 "name=member&idUser=1&idAssociation=1"
post http://localhost:3000/roles 201 "name=president&idUser=2&idAssociation=1"

post http://localhost:3000/minutes 201 "content=blablabla&idVoters[]=1&idVoters[]=2&date=12/12/2021&idAssociation=1"

get http://localhost:3000/minutes/1 200
get http://localhost:3000/minutes/2 404

put http://localhost:3000/minutes/1 200 "idAssociation=1&content=newblabla"

delete http://localhost:3000/minutes/1 200
get http://localhost:3000/minutes/1 404