FROM phusion/baseimage
MAINTAINER Brian Morton "bmorton@yammer-inc.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y curl ca-certificates git build-essential libtool autoconf libtcmalloc-minimal4

# Install ruby-install
WORKDIR /tmp
ADD https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz /tmp/ruby-install.tar.gz
RUN tar -xzvf ruby-install.tar.gz
WORKDIR /tmp/ruby-install-0.4.3
RUN make install

# Install Ruby 1.9.3-p547 w/railsexpress patches
RUN ruby-install -p https://gist.githubusercontent.com/bmorton/46e037136741d95c9926/raw/74b8d615550d46a865921ccc8391fd02b01d2de8/railsexpress-1.9.3-p547.patch \
 ruby 1.9.3-p547 -- --enable-shared CFLAGS="-O3"

# Install chruby
WORKDIR /tmp
ADD https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz /tmp/chruby.tar.gz
RUN tar -xzvf chruby.tar.gz
WORKDIR /tmp/chruby-0.3.8
RUN make install

RUN echo '[ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ] || return' >> /etc/profile.d/chruby.sh
RUN echo 'source /usr/local/share/chruby/chruby.sh' >> /etc/profile.d/chruby.sh
RUN echo 'chruby ruby' >> /etc/profile.d/default_ruby.sh
RUN echo "export LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4:${LD_PRELOAD}" >> /etc/profile.d/exports.sh

ENV RUBY_HEAP_MIN_SLOTS 800000
ENV RUBY_GC_MALLOC_LIMIT 60000000
ENV RUBY_FREE_MIN 200000
ENV RUBY_HEAP_SLOTS_GROWTH_FACTOR 1.25

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /
