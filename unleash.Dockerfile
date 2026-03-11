FROM unleashorg/unleash-server:7.0.0

COPY ./unleash.js index.js

ENTRYPOINT ["node", "/unleash/index.js"]
