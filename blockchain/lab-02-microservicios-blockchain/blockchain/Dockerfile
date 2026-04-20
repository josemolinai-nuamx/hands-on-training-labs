FROM node:22-alpine

RUN apk add --no-cache bash curl

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN chmod +x ./scripts/start.sh

EXPOSE 8545

CMD ["npm", "run", "start"]
