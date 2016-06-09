FROM ruby:1.9.3

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update -y && \
  apt-get install -y unzip xvfb qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

RUN apt-get install -y nodejs npm nodejs-legacy mysql-client iceweasel

# Default configuration
ENV DISPLAY :20.0
ENV SCREEN_GEOMETRY "1440x900x24"

# Set working directory to canonical directory
ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
RUN gem uninstall bundler
RUN gem install bundler

ADD Gemfile* $APP_HOME/
RUN bundle -v
RUN bundle install

ADD . $APP_HOME

# Adds ability to run xvfb in daemonized mode
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ADD xvfb-daemon-run /usr/bin/xvfb-daemon-run
RUN chmod a+x /usr/bin/xvfb-daemon-run

ENTRYPOINT ["/usr/bin/xvfb-daemon-run"]
