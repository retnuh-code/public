FROM node:20

# Use the latest available stable version of npm
RUN npm install -g npm@11.2.0

# Install backend dependencies
RUN apt update && apt install -y \
  python3 \
  make \
  g++ \
  libxml2-utils \
  libxslt1-dev \
  build-essential

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "server.js"]
