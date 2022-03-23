#!/bin/sh

request() {
    method=${1}
    url=${2}
    expected_http_status=${3}
    parameters=${4}
    if [ -z "${parameters}" ]
    then
        echo "curl -X ${method} -o /tmp/output_curl -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}"
        http_status=`curl -X ${method} -o /tmp/output_curl -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}`
    else
        echo "curl -X ${method} -d '${parameters}' -o /tmp/output_curl -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}"
        http_status=`curl -X ${method} -d ${parameters} -o /tmp/output_curl -s -w "%{http_code}\n" --header 'Accept: application/json' ${url}`
    fi
    cat /tmp/output_curl
    echo ""
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

get http://localhost:3000/users/1/roles 200
get http://localhost:3000/users/2/roles 200

get http://localhost:3000/roles/users/member 200
get http://localhost:3000/roles/users/president 200

get http://localhost:3000/associations/1/minutes 200 "sort=date"
get http://localhost:3000/associations/1/minutes 200 "sort=date&order=ASC"