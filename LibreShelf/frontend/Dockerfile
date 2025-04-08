FROM node:20

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "3000"]
