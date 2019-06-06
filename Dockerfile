FROM jekyll/jekyll
EXPOSE  4000
WORKDIR  /app
COPY . /app
CMD ["jekyll", "serve", "--force_polling", "-s", "./"]