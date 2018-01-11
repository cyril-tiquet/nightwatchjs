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
RUN apt-get install -y wget
RUN apt-get install -y unzip
RUN apt-get install -y git
RUN apt-get install -y xvfb
COPY xvfb.sh xvfb.sh

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION
# Latest released version will be used by default
#============================================
#ARG CHROME_VERSION="stable"
ARG CHROME_VERSION="63.0.3239.132-1"
RUN apt-get install -y fonts-liberation gconf-service libappindicator1 libasound2 libatk1.0-0 libcairo2 libcups2 libdbus-1-3 libfontconfig1 libnspr4 libnss3 libxss1 lsb-release xdg-utils
RUN wget --no-verbose -O /tmp/google-chrome-stable_${CHROME_VERSION}_amd64.deb  https://s3-eu-west-1.amazonaws.com/r7chrome.deb/google-chrome-stable_${CHROME_VERSION}_amd64.deb
RUN dpkg -i /tmp/google-chrome-stable_${CHROME_VERSION}_amd64.deb
RUN rm /tmp/google-chrome-stable_${CHROME_VERSION}_amd64.deb

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


#============================================
# Start X11 virtual FB
#============================================
CMD xvfb.sh
