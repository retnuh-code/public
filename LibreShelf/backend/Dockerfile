FROM node:20

WORKDIR /app

# Copy package.json and install dependencies
COPY backend/package.json ./
RUN npm install

# Copy the rest of your backend code
COPY backend ./ 

EXPOSE 4000

CMD ["npm", "start"]
