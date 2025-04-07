FROM node:20

# Install system deps for XML parsing etc.
RUN apt update && apt install -y \
  python3 \
  make \
  g++ \
  libxml2-utils \
  libxslt1-dev \
  build-essential && \
  apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 4000
CMD ["node", "server.js"]
