FROM node:12-alpine as build
RUN apk update

LABEL maintainer="Tutu Godfrey <godfrey_tutu@yahoo.com>"
LABEL description="Docker image for todo app frontend"

WORKDIR /app
COPY package.json* webpack.config.js .babelrc  ./
RUN npm install
COPY client ./client
COPY public ./public
COPY nginx.conf ./
# API_URL is the url to forward api requests to backend server
# This may be the uri of an nginx if you are 
# using nginx as a proxy server
# or the address (hostname, IP) of a load balancer server
ARG API_URL
ENV API_URL=${API_URL}
RUN echo API_URL=$API_URL >> .env
RUN echo API_URL= >> .env.example 
RUN npm run build

# Use intermediate build
FROM nginx:latest
RUN apt update; apt install vim -y
WORKDIR /
COPY --from=build /app/public /usr/share/nginx/html/public/
COPY --from=build /app/public/index.html /usr/share/nginx/html/ 
COPY --from=build /app/public/bundle.js /usr/share/nginx/html/
COPY --from=build /app/nginx.conf /etc/nginx/nginx.conf
