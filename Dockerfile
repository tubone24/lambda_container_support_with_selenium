FROM python:3.7-alpine

ENV PYTHONIOENCODING utf-8
WORKDIR /app

RUN apk add --update \
    # Add Dependencies for compile AWS Lambda ric
      build-base \
      libtool \
      autoconf \
      automake \
      libexecinfo-dev \
      make \
      cmake \
      libcurl \
      wget \
      bash \
      which \
      groff \
    # Add chromium and font dependences
      udev \
      ttf-freefont \
      terminus-font \
      freetype \
      freetype-dev \
      harfbuzz \
      fontconfig \
      chromium \
      chromium-chromedriver
# Add Japanese font
RUN mkdir noto \
    && wget -P /app/noto https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
    && wget -P /app/noto https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip \
    && unzip /app/noto/NotoSansCJKjp-hinted.zip -d /app/noto \
    && unzip -o /app/noto/NotoSerifCJKjp-hinted.zip -d /app/noto \
    && mkdir -p /usr/share/fonts/noto \
    && cp /app/noto/*.otf /usr/share/fonts/noto \
    && chmod 644 -R /usr/share/fonts/noto/ \
    && fc-cache -fv \
    && rm -rf /app/noto \
    && mkdir -p /root/.config/fontconfig
ADD ./font/fonts.conf /etc/fonts/local.conf
ADD ./font/*.ttf /usr/share/fonts/TTF/
RUN fc-cache -fv

# timezone
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && \
    apk del tzdata

# Add Python Scripts Depends
RUN pip install selenium \
    && pip install requests \
    && pip install boto3 \
    && pip install --target /app awslambdaric

ADD ./app/ /app
RUN chmod +x app.py
RUN pip freeze


ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]