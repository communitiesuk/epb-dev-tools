FROM unleashorg/unleash-server:7.5.1

COPY ./unleash.js index.js

ENTRYPOINT ["node", "/unleash/index.js"]
