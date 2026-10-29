FROM unleashorg/unleash-server:8

COPY ./unleash.js index.js

ENTRYPOINT ["node", "/unleash/index.js"]
