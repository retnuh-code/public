# Use the official Node.js LTS image
FROM node:20

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 4000

# Start the application
CMD ["node", "server.js"]
