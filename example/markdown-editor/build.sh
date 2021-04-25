#!/bin/sh
dune build client/index.bc.js
mkdir -p static
cp ../../_build/default/example/markdown-editor/client/index.bc.js static/index.js
dune exec -- server/server.exe