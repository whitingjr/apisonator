#!/bin/bash
# 3scale (operations@3scale.net)

# Optionally used to set up the Ruby/Bundler environment.
if [ -n "${ENV_SETUP}" ]; then
  eval "${ENV_SETUP}"
fi

set -u

if [[ -v LOG_FILE ]]; then
  tail -f $LOG_FILE &
fi

if [[ -v ERROR_LOG_FILE ]]; then
  tail -f $ERROR_LOG_FILE 1>&2 &
fi

#echo "JRUBY_INSTALL_HOME is [$JRUBY_INSTALL_HOME]"
#echo "bash script params [$@]"
exec $JRUBY_INSTALL_HOME/bin/jruby -S bundle exec "$@"
#exec $JRUBY_INSTALL_HOME/bin/jruby -J-XX:+UnlockDiagnosticVMOptions -J-XX:MaxJavaStackTraceDepth=32768 -J-XX:VMThreadStackSize=32768 -J-XX:+PrintFlagsFinal -S bundle exec "$@"
