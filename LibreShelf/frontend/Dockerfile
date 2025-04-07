FROM node:20

# Upgrade npm first (only runs once unless base image changes)
RUN npm install -g npm@latest

WORKDIR /app

# Only copy package files first so we cache installs
COPY package*.json ./

# Install deps once, then cache
RUN npm install

# Now copy the full app
COPY . .

# Build once, then serve
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "preview"]
