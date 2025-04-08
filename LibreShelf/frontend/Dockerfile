FROM node:20

# Use latest stable npm
RUN npm install -g npm@11.8.0

WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "run", "preview"]
