#!/bin/bash
#

# Save the CLI parameters.  There should be 3!
#
if [ $# -lt 3 ]; then
  echo "Usage:  lookup-patter1 <sa-name> <tok output file> <ca output file>"
  exit 1
fi

SA_NAME=$1
TOK_FILE=$2
CA_FILE=$3

SA_SECRET_0=$(oc get sa ${SA_NAME} -o json | jq '.secrets[0].name' | tr -d '"')
if [[ ${SA_SECRET_0} != ${SA_NAME}-token* ]]; then
  SA_SECRET_1=$(oc get secret ${SA_SECRET_0} -o json | jq ".metadata.ownerReferences[].name" | tr -d '"' | xargs)
else
  SA_SECRET_1=$SA_SECRET_0
fi
oc get secret $(echo ${SA_SECRET_1}) -o json | jq '.data.token' | xargs | base64 --decode > ${TOK_FILE}
oc get secret $SA_SECRET_1 -o json | jq '.data["ca.crt"]' | xargs | base64 --decode > ${CA_FILE}
