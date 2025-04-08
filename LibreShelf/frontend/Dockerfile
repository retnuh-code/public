FROM node:20-bullseye

# Enable npm 11
RUN corepack enable && corepack prepare npm@11.2.0 --activate

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

# Build production output
RUN npm run build

# Serve the built static site using Vite's preview server
EXPOSE 3000
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "3000"]
