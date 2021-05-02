# Build the frontend app will produce the public dir
FROM node:12-alpine
RUN apk update && apk add git

LABEL maintainer="Tutu Godfrey <godfrey_tutu@yahoo.com>"
LABEL description="Docker image for todo app backend"
 
RUN git clone http://github.com/tutugodfrey/modela
WORKDIR /app
COPY package*.json /app/
RUN npm install

# get env variable from arg or use defaults
ARG PORT=3005
ARG JWT_SECRET

# add to environment variable
RUN touch .env.example
ENV PORT=${PORT}
ENV JWT_SECRET=${JWT_SECRET}
ENV USE_DB # if supplied should be 1. To enable persistent storage
ENV DATABASE_URL # Provide the endpoint to reach the database
RUN npm install --production
COPY public/background-image.jpg ./public
COPY src ./src
COPY helpers ./helpers
COPY setup ./setup
COPY .babelrc jest.config.js /app/
EXPOSE $PORT

WORKDIR /modela
RUN npm install && npm test && npm link

WORKDIR /app
RUN npm link data-modela

# start the app
CMD ["npm", "start"]
