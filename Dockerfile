FROM ruby:2.2.4
MAINTAINER Nhan Tran <tranphanquocnhan@gmail.com>

RUN gem install jekyll
RUN mkdir /root/myblogs
WORKDIR /root/myblogs
VOLUME ["/root/myblogs"]
RUN gem install jekyll-paginate
EXPOSE 4000
CMD ["jekyll", "serve", "-H", "0.0.0.0"]