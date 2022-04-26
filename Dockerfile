# syntax=docker/dockerfile:1
FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install -y nodejs libmariadb-dev-compat libmariadb-dev 
WORKDIR /app
RUN rm -rf /app/config/master.key 
RUN rm -rf /app/config/credentials.yml.enc
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoints/docker-entrypoint.sh /usr/bin/
COPY entrypoints/database-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/database-entrypoint.sh

ENTRYPOINT ["database-entrypoint.sh"]
EXPOSE 3001

COPY . /app

# Configure the main process to run when running the image
CMD ["rails", "server", "-p", "3001", "-b", "0.0.0.0" ]
