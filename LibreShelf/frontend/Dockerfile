FROM node:20-bullseye

# Enable Corepack and upgrade to npm 11.2.0 fast
RUN corepack enable && corepack prepare npm@11.2.0 --activate

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000"]

