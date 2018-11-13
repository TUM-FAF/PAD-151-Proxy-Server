FROM ruby:2.5

RUN mkdir /myapp
WORKDIR /myapp
COPY . /myapp
RUN bundle install
# change port if needed
EXPOSE 9292
# run the application
CMD ["bundle", "exec", "app.rb"]