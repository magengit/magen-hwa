FROM magendocker/magen-core:latest
MAINTAINER Alena Lifar

VOLUME ["/opt/server"]
WORKDIR /opt/server
ENV PYTHONPATH $PYTHONPATH:/opt/server:/opt/server/hwa:/opt/server/hwa/hwa_server

RUN rm -rf __pycache__/
RUN rm -rf tests/__pycache__/

WORKDIR /opt/server/hwa

RUN rm -rf __pycache__/
RUN rm -rf tests/__pycache__/

# For production:
# RUN pip3 install magen-hwa-service

# For dev:
WORKDIR /tmp
COPY magen_hwa_service-1.0a2-py3-none-any.whl /tmp
RUN pip3 install magen_hwa_service-1.0a2-py3-none-any.whl

WORKDIR /opt/server/hwa
