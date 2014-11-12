#!/bin/bash
set -u -e

CURRENT_DIR="$( cd "$( dirname $BASH_SOURCE )" && pwd )"
cd $CURRENT_DIR/../
source ~/.nvm/nvm.sh
nvm install 0.10
nvm use 0.10
npm install node-pre-gyp
npm install aws-sdk
./node_modules/.bin/node-pre-gyp info
npm cache clean
rm -rf sdk

function doit () {
    NVER=$1
    nvm install $1
    nvm use $1
    npm install --build-from-source
    npm test
    node ./node_modules/.bin/node-pre-gyp package testpackage
    node ./node_modules/.bin/node-pre-gyp testpackage
    npm ls
    node ./node_modules/.bin/node-pre-gyp publish
    node ./node_modules/.bin/node-pre-gyp info
    rm -rf {build,lib/binding}
    npm install --fallback-to-build=false
    npm test
}

doit 0.8
doit 0.10
doit 0.11.13

# to avoid then publishing with node v0.11.x
# https://github.com/npm/npm/issues/5515#issuecomment-46688278
nvm use 0.10