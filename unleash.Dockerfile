FROM unleashorg/unleash-server:8.2.0

COPY ./unleash.js index.js

ENTRYPOINT ["node", "/unleash/index.js"]
