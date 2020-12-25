FROM python:3.7-alpine

ENV PYTHONIOENCODING utf-8
WORKDIR /app

ADD requirements.txt /app
ADD ./font/fonts.conf /etc/fonts/local.conf
ADD ./font/*.ttf /usr/share/fonts/TTF/

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
        tzdata \
    # Add chromium and font dependences
      udev \
        ttf-freefont \
        freetype \
        fontconfig \
        chromium \
        chromium-chromedriver  && \
    # Python dependencies
      pip install -r requirements.txt && \
        pip install --target /app awslambdaric && \
        rm /app/requirements.txt && \
     # Change Timezone
      cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
        echo "Asia/Tokyo" > /etc/timezone && \
     # Add noto fonts
      mkdir noto && \
        wget -P /app/noto https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip && \
        wget -P /app/noto https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip && \
        unzip /app/noto/NotoSansCJKjp-hinted.zip -d /app/noto && \
        unzip -o /app/noto/NotoSerifCJKjp-hinted.zip -d /app/noto && \
        mkdir -p /usr/share/fonts/noto && \
        cp /app/noto/*.otf /usr/share/fonts/noto && \
        chmod 644 -R /usr/share/fonts/noto/ && \
        rm -rf /app/noto && \
        fc-cache -fv && \
      apk del \
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
        tzdata \
        freetype-dev

ADD ./app/ /app

ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]