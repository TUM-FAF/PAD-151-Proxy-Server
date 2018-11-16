FROM ruby:2.5

RUN mkdir /myapp
WORKDIR /myapp
COPY . /myapp
RUN gem install redis
RUN bundle install
ENV PROXY_PORT 9292
# change port if needed
EXPOSE $PROXY_PORT
# run the application
CMD ["bundle", "exec", "ruby", "app.rb"]