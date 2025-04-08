FROM node:20

# Install backend dependencies (we skip global npm update)
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
