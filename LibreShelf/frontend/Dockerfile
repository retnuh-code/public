FROM node:20

# Upgrade npm
RUN npm install -g npm@latest

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "preview"]
