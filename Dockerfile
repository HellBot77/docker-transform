FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/ritz078/transform.git && \
    cd transform && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git

FROM node:16 AS build

WORKDIR /transform
COPY --from=base /git/transform .
RUN yarn --network-timeout 1000000 && \
    export NODE_ENV=production && \
    export NEXT_TELEMETRY_DISABLED=1 && \
    yarn build

FROM node:16-alpine

WORKDIR /transform
COPY --from=build /transform/next.config.js ./
COPY --from=build /transform/public ./public
COPY --from=build /transform/.next ./.next
COPY --from=build /transform/node_modules ./node_modules
COPY --from=build /transform/package.json ./package.json
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
EXPOSE 3000
CMD ["yarn", "start"]
