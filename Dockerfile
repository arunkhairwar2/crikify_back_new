# Common build stage
FROM node:22-alpine AS common-build-stage

WORKDIR /app

COPY package*.json ./
RUN npm ci

EXPOSE 3000

# Development build stage
FROM common-build-stage AS development-build-stage

ENV NODE_ENV development

COPY prisma ./prisma
COPY prisma.config.ts ./
COPY tsconfig.json ./
COPY package.json ./
COPY src ./src
COPY src/config ./src/config

USER node

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["npm", "run", "dev"]

# Production build stage
FROM common-build-stage AS production-build-stage

ENV NODE_ENV production

COPY . .

RUN npx prisma generate

RUN npm run build

USER node

CMD ["npm", "start"]