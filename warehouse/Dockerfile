FROM ruby:2.5

WORKDIR /myapp
COPY . /myapp
RUN bundle install
ENV WAREHOUSE_PORT 9191
EXPOSE $WAREHOUSE_PORT

# run the application
CMD ["bundle", "exec", "ruby", "app.rb"]