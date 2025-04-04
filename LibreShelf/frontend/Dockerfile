FROM node:20

WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "run", "preview", "--", "--host", "--port", "3000"]
