FROM ruby:onbuild

EXPOSE 5000

CMD ["foreman", "start", "-d", "/usr/src/app"]]
