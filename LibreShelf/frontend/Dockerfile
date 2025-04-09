# Use official Node.js image
FROM node:20 as builder

# Create app directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source
COPY . .

# Build the app
RUN npm run build

# Use nginx to serve built files
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
