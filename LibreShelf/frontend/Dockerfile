FROM node:20

WORKDIR /app

# Upgrade npm to latest major (11.2.0 as of now)
RUN npm install -g npm@11.2.0

COPY package.json ./
RUN npm install

COPY . .

RUN npm run build

CMD ["npm", "run", "preview"]
