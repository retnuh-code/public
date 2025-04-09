FROM node:20 AS builder

WORKDIR /app

RUN corepack enable && corepack prepare yarn@stable --activate

COPY package.json ./
RUN yarn install

COPY . .

RUN yarn build
