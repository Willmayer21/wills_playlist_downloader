#!/bin/sh
exec rails server -b 0.0.0.0 -p ${PORT:-3000}
