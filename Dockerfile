# pull official node image
FROM node:10

# Create app directory
LABEL maintainer="Tutu Godfrey <godfrey_tutu@yahoo.com>"
LABEL description="A simple todo API to make is easy for users to track progress on their tasks"

# get port value from arg
ARG port=3005
ENV PORT=$port


# Create app directory
WORKDIR /app

COPY package*.json /app/

RUN npm install
COPY . /app/

EXPOSE $port
CMD ["npm", "start"]
