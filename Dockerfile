FROM ruby:2.7-alpine
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# update apk
RUN apk update && \
  apk upgrade && \
  apk add --no-cache linux-headers libxml2-dev make gcc libc-dev build-base curl-dev python2 py-pip nodejs npm tzdata ruby ruby-dev

# install aws-cli
RUN pip install awscli

# install boto3
RUN pip install boto3

# install serverless framework
RUN npm install -g serverless

# set aws key 
RUN sls config credentials --provider aws --key $AWS_ACCESS_KEY_ID --secret $AWS_SECRET_ACCESS_KEY

# change work directory
RUN mkdir -p /app
WORKDIR /app
