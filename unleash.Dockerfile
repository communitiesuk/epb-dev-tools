FROM unleashorg/unleash-server:4.8.2-node16-alpine

COPY ./unleash.js index.js
COPY ./unleash-auth-hook.js unleash-auth-hook.js
