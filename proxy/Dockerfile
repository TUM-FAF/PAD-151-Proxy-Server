FROM ruby:2.5

WORKDIR /myapp
COPY . /myapp
RUN bundle install
ENV PROXY_PORT 9292
EXPOSE $PROXY_PORT
# run the application
CMD ["bundle", "exec", "ruby", "app.rb"]
