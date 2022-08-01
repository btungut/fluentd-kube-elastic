FROM fluent/fluentd:v1.15-1

USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-elasticsearch \
 && sudo gem install fluent-plugin-kubernetes_metadata_filter \
 && sudo gem install fluent-plugin-multiprocess \
 && sudo gem install fluent-plugin-multi-format-parser \
 && sudo gem install fluent-plugin-concat \
 && sudo gem install fluent-plugin-rewrite-tag-filter \
 && sudo gem install fluent-plugin-prometheus \
 && sudo gem install fluent-plugin-script \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN rm -rf /fluentd/etc