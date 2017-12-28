FROM  alpine:3.4
LABEL maintainer=jon@jaggersoft.com

USER root
RUN adduser -D -H -u 19661 cyber-dojo

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby+
# bundle install needs zlib-dev for nokogiri
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    ruby ruby-io-console ruby-dev ruby-irb ruby-bundler ruby-bigdecimal \
    bash \
    tzdata \
    zlib-dev

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install web service
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY Gemfile ${CYBER_DOJO_HOME}
RUN  echo 'gem: --no-document' > ~/.gemrc

RUN apk --update \
    add --virtual build-dependencies build-base \
    && bundle config --global silence_root_warning 1 \
    && cd ${CYBER_DOJO_HOME} \
    && bundle install \
    && apk del build-dependencies

RUN cat ${CYBER_DOJO_HOME}/Gemfile.lock

COPY . ${CYBER_DOJO_HOME}
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}

WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000

CMD [ "./run_rails_server.sh" ]
