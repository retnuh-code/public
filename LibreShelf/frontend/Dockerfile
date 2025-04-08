FROM node:20

# Upgrade npm to 11.2.0
RUN npm install -g npm@11.2.0

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev"]