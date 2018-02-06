FROM node
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY src ./src
ADD package.json ./
RUN npm install

CMD ["npm", "start"]