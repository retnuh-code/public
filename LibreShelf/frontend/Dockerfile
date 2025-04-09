FROM node:20-bullseye

RUN corepack enable && corepack prepare npm@11.2.0 --activate

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000"]
