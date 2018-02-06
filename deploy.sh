#!/usr/bin/env bash

show_help() {
    echo "Usage: deploy.sh [options]" >&2
    echo "Options:" >&2
    echo "--help                    Help instructions" >&2
    echo "--mongo-uri               Mongo DB URI. Default: mongodb://mongo:27017/komoot" >&2
    echo "--sqs-url                 Sqs url to consume notifications (Required)" >&2
    echo "--sender-email            Email address for using on notification emails 'from' section (Required)" >&2
    echo "--aws-access-key          AWS Access Key (Required)" >&2
    echo "--aws-secret-access-key   AWS Secret Access Key (Required)" >&2
    echo "--aws-region              AWS Region (Required)" >&2

    exit 1
}

MONGO_URI=mongodb://mongo:27017/komoot

while :; do
    case $1 in
        --mongo-uri)
            if [ -n "$2" ]; then
                MONGO_URI=$2
            fi
            shift
        ;;
        --sqs-url)
            if [ -n "$2" ]; then
                SQS_URL=$2
            else
                printf 'No SQS_URL provided.\n' >&2
                show_help
            fi
            shift
        ;;
        --sender-email)
            if [ -n "$2" ]; then
                SENDER_EMAIL=$2
            else
                printf 'No SENDER_EMAIL Provided.\n' >&2
                show_help
            fi
            shift
        ;;
        --aws-access-key)
            if [ -n "$2" ]; then
                AWS_ACCESS_KEY=$2
            else
                printf 'No AWS_ACCESS_KEY Provided.\n' >&2
                show_help
            fi
            shift
        ;;
        --aws-secret-access-key)
            if [ -n "$2" ]; then
                AWS_SECRET=$2
            else
                printf 'No AWS_SECRET Provided.\n' >&2
                show_help
            fi
            shift
        ;;
        --aws-region)
            if [ -n "$2" ]; then
                AWS_REGION=$2
            else
                printf 'No AWS_REGION Provided.\n' >&2
                show_help
            fi
            shift
        ;;
        --help)
            show_help
        ;;
        --)              # End of all options.
            shift
            break
        ;;
        -?*)
            printf c
            show_help
        ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac
    shift
done


check_params() {
    if [ -z "${SQS_URL}" ] ||
        [ -z "${SQS_URL}" ] ||
        [ -z "${SENDER_EMAIL}" ] ||
        [ -z "${AWS_ACCESS_KEY}" ] ||
        [ -z "${AWS_SECRET}" ] ||
        [ -z "${AWS_REGION}" ]; then
        show_help
    fi
}

check_params

echo "Creating AWS Instance ..."
docker-machine create --driver amazonec2 digest-notifier

echo "Switching to AWS docker context..."
eval $(docker-machine env digest-notifier)

echo "Building docker image ..."
docker build -t huseyinbabal/digest-notifier .

echo "Creating bridge network ..."
docker network create --driver bridge digest_notifier

echo "Mongo is starting ..."
docker run -d --network=digest_notifier --name=mongo mongo

echo "Digest notifier is starting ..."
docker run -d --network=digest_notifier --name=digest-notifier \
    -e MONGO_URI=${MONGO_URI} \
    -e NOTIFICATION_SQS_URL=${SQS_URL} \
    -e SENDER_EMAIL_ADDRESS=${SENDER_EMAIL} \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY} \
    -e AWS_DEFAULT_REGION=${AWS_REGION} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET} \
    huseyinbabal/digest-notifier

echo "Application deployment finished. You will get notifications per hour."
