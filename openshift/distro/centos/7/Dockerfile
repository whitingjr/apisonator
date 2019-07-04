# 3scale Backend CentOS image
#
# This image is meant for flexibility building different configurations.
#
# Knobs you should know about:
#
# - RUBY_SCL: Software Collections Library for the Ruby version used.
# - BUILD_DEP_PKGS: Packages needed to build/install the project.
# - CACHE_FRIENDLY: Improve caching when rebuilding at the cost of bigger size.
# - GEM_UPDATE: Update Rubygems to the latest version.
# - BUNDLE_VERSION_MATCH: Install the Bundler version used by the lockfile
#                         instead of using the SCL version.
# - BUNDLE_GEMFILE: Gemfile name to pin Bundler to.
# - BUNDLE_WITHOUT: List of Bundler groups to skip.
# - DELETE_UNUSED_GEMFILES: Deletes unused Gemfiles in the root directory.
# - CONFIG_SAAS: true for a SaaS image. false for an on-premises image.
# - PUMA_WORKERS: Default number of Puma workers to serve the app.
#
# Profiles you should use:
#
# You can use variations on the values of arguments, but you usually want one
# of the following two use cases:
#
# - Development/Test: just use default values.
# - Release:
#   - CACHE_FRIENDLY: false
#   - GEM_UPDATE: false
#   - BUNDLE_VERSION_MATCH: false
#   - BUNDLE_GEMFILE: Gemfile for SaaS, Gemfile.on_prem for on-premises.
#   - BUNDLE_WITHOUT: development:test
#   - DELETE_UNUSED_GEMFILES: true
#   - CONFIG_SAAS: true for SaaS, false for on-premises.
#   - PUMA_WORKERS: number of Puma worker processes - depends on intended usage,
#                   with number of cpus being a good heuristic.
#

FROM jruby:9.2-jdk

ARG RUBY_SCL=rh-ruby23
ARG BUILD_DEP_PKGS="git policycoreutils restorecon"
# Turn off for release mode to produce smaller layers.
ARG CACHE_FRIENDLY=true

#RUN apt-get -y update 
#RUN apt-get -y upgrade 
#RUN apt -y install software-properties-common setools selinux-basics selinux-policy-default
#RUN setenforce Permissive

#RUN apt-get install -y policycoreutils restorecon --no-install-recommends ; rm -rf /var/lib/apt/lists/*
#RUN semanage fcontext -a -t lib_t /opt/jruby/lib/jni/x86_64-Linux/libjffi-1.2.so \
# && restorecon -v /opt/jruby/lib/jni/x86_64-Linux/libjffi-1.2.so

RUN mkdir -p /deployments

ENV JAVA_APP_DIR=/deployments \
    JAVA_MAJOR_VERSION=8

# /dev/urandom is used as random source, which is prefectly safe
# according to http://www.2uo.de/myths-about-urandom/
#RUN yum install -y \
#       openssl-devel.x86_64 java-1.8.0-openjdk $BUILD_DEP_PKGS \
# && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security

WORKDIR /tmp/app

# Gem updating should be turned off for productisation
ARG GEM_UPDATE=true
# Bundler should be kept as-is for productisation
ARG BUNDLE_VERSION_MATCH=true
ARG BUNDLE_GEMFILE=Gemfile.on_prem
ARG BUNDLE_WITHOUT=development:test

# Install and/or update Rubygems and Bundler, and configure the latter.
COPY ${BUNDLE_GEMFILE}.lock ./

#RUN set -o pipefail \
RUN if test "${GEM_UPDATE}x" = "truex"; then \
      gem update --system -N ; \
    fi \
 && BUNDLED_WITH=$(cat ${BUNDLE_GEMFILE}.lock | \
      grep -A 1 "^BUNDLED WITH" | tail -n 1 | sed -e 's/\s//g') \
 && echo "> gem install -N bundler --version xxxx" \
 && gem install -N bundler --version ${BUNDLED_WITH}  \
 && echo "> gem install bundle" \
 && gem install -N bundle \
 && echo "> bundle config ....." \
 && bundle config --local silence_root_warning 1 \
 && bundle config --local disable_shared_gems 1 \
 && bundle config --local without ${BUNDLE_WITHOUT}

COPY . ./

ARG DELETE_UNUSED_GEMFILES=true
# Turn off for productisation
ARG CONFIG_SAAS=false

# Switch the shell to one that supports indirection
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Builds a clean source tree and deploys it with Bundler.
# Sets the right configuration and permissions.
RUN cp -n openshift/3scale_backend.conf /etc/ \
 && chmod 644 /etc/3scale_backend.conf \
 && BACKEND_VERSION=$(gem build 3scale_backend.gemspec | \
      sed -n -e 's/^\s*Version\:\s*\([^[:space:]]*\)$/\1/p') \
 && gem unpack "3scale_backend-${BACKEND_VERSION}.gem" --target=/opt/ruby \
 && cd "/opt/ruby/3scale_backend-${BACKEND_VERSION}" \
 && mkdir -p .bundle/ \
 && cp -a /usr/local/bundle/config .bundle/ \
 && if test "${DELETE_UNUSED_GEMFILES}x" = "truex"; then \
      echo "Deleting the following unused Gemfile files:"; \
      find . -maxdepth 1 -regex \./Gemfile"\(\..*\)?" \
      ! -regex \./$(sed -e 's/[^^]/[&]/g; s/\^/\\^/g' <<< ${BUNDLE_GEMFILE})"\(\.lock\)?" \
      ! -name Gemfile.base -print -delete; \
    fi \
 && if test "${CACHE_FRIENDLY}x" != "truex"; then \
      apt-get -y install ${BUILD_DEP_PKGS} ; \
    fi \
 && echo "> bundle package --all" \
 && bundle package --all \
 && echo "> bundle install --binstubs" \
 && bundle install --binstubs \
 && echo "> bundle install --deployment --jobs" \
 && bundle install --deployment --jobs $(grep -c processor /proc/cpuinfo) \
 && echo "gem update --system" \
 && gem update --system \
 && echo "> bundle check" \
 && gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" \
# Bundler < 1.12.0 needs fixing for git gems with extensions (Puma)
# && if ruby -e "begin; require 'rubygems'; Gem::Specification.find_by_name('bundler').version < Gem::Version.new('1.12.0') && exit(0); rescue; end; exit(1)"; then \
#      echo "[WARNING] Old Bundler requires fixing git gems with extensions (Puma)" ; \
#      PUMA_DIR=$(bundle show puma) \
#      && ln -s $(find "${PUMA_DIR}" -name puma_http11.so) "${PUMA_DIR}"/lib/puma ; \
#    fi \
 && ln -s ${PWD} /opt/app \
# && yum -y remove ${BUILD_DEP_PKGS} \
# && yum -y autoremove \
# && yum -y clean all \
 && rm -rf /var/lib/apt/lists/* \
 && if test "${CONFIG_SAAS}x" != "truex"; then \
      cp /tmp/app/openshift/config/puma.rb ./config/ ; \
    fi \
 && cp -n /tmp/app/openshift/backend-cron /usr/local/sbin/backend-cron \
 && cp -n /tmp/app/openshift/entrypoint.sh ./ \
 && mkdir -p -m 0770 /var/run/3scale/ \
 && mkdir -p -m 0770 /var/log/backend/ \
 && touch /var/log/backend/3scale_backend{,_worker}.log \
 && chmod g+rw /var/log/backend/3scale_backend{,_worker}.log \
 && find . -not -uid $(stat -c "%u" .) -exec chown --reference=. {} \; \
 && echo "Finished building final layer."

EXPOSE 3000

USER 1001

WORKDIR /opt/app

ARG PUMA_WORKERS=1
ARG RACK_ENV=production

# Set TZ to avoid glibc wasting time with unneeded syscalls
ENV TZ=:/etc/localtime \
    HOME=/tmp/ \
    JRUBY_INSTALL_HOME=$JRUBY_INSTALL_HOME \
    #ENV_SETUP=". scl_source enable ${RUBY_SCL}" \
    # App-specific env
    RACK_ENV=${RACK_ENV} \
    CONFIG_SAAS=${CONFIG_SAAS} \
    CONFIG_LOG_PATH=/tmp/ \
    CONFIG_NOTIFICATION_BATCH=1 \
    CONFIG_WORKERS_LOG_FILE=/dev/stdout \
    PUMA_WORKERS=${PUMA_WORKERS}

ENTRYPOINT ["/bin/bash", "--", "/opt/app/entrypoint.sh"]
