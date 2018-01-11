#============================================
#
# Full nightwatch.js middleware Dockerfile
#
#============================================

FROM ubuntu:16.04
MAINTAINER Jean-Thierry BONHOMME <jtbonhomme@gmail.com>

#============================================
# Basic tools and update
#============================================
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y xvfb
COPY xvfb.service /etc/systemd/system
RUN systemctl daemon-reload
RUN systemctl enable xvfb.service
RUN systemctl start xvfb.service

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION
# Latest released version will be used by default
#============================================
#ARG CHROME_VERSION="stable"
ARG CHROME_VERSION="62.0.3202.94"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome=${CHROME_VERSION:stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
#ARG CHROME_DRIVER_VERSION="latest"
ARG CHROME_DRIVER_VERSION="2.29"
RUN CD_VERSION=$(if [ ${CHROME_DRIVER_VERSION:-latest} = "latest" ]; then echo $(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE); else echo $CHROME_DRIVER_VERSION; fi) \
  && echo "Using chromedriver version: "$CD_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
  && rm -rf /var/local/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /var/local \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /var/local/chromedriver /var/local/chromedriver-$CD_VERSION \
  && chmod 755 /var/local/chromedriver-$CD_VERSION \
  && sudo ln -fs /var/local/chromedriver-$CD_VERSION /usr/bin/chromedriver

#============================================
# Selenium
#============================================
# can specify versions by SELENIUM_MAJOR_VERSION and SELENIUM_MINOR_VERSION
#============================================
ARG SELENIUM_MAJOR_VERSION="3.4"
ARG SELENIUM_MINOR_VERSION="3.4.0"
RUN  wget --no-verbose https://selenium-release.storage.googleapis.com/$SELENIUM_MAJOR_VERSION/selenium-server-standalone-$SELENIUM_MINOR_VERSION.jar \
    -O /var/local/selenium-server-standalone-$SELENIUM_MINOR_VERSION.jar \
  && chmod 755 /var/local/selenium-server-standalone-$SELENIUM_MINOR_VERSION.jar

