FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/ritz078/transform.git && \
    cd transform && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git

FROM --platform=$BUILDPLATFORM node:20 AS build

WORKDIR /transform
COPY --from=base /git/transform .
RUN yarn --frozen-lockfile && \
    yarn build && \
    rm -rf node_modules && \
    npm install --global patch-package && \
    yarn --frozen-lockfile --production

FROM node:alpine

WORKDIR /transform
COPY --from=build /transform/package.json ./
COPY --from=build /transform/node_modules ./node_modules
COPY --from=build /transform/.next ./.next

EXPOSE 3000
ENV NODE_ENV=production
CMD [ "npm", "start" ]
