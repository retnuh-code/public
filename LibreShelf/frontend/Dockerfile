FROM node:20

# Use the latest available stable version of npm
RUN npm install -g npm@11.2.0

WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "run", "preview"]
