'use strict';

const unleash = require('unleash-server');

let options = {
    authentication: {
        type: "none"
    }
};

unleash.start(options);