FROM registry.access.redhat.com/ubi9/ubi:latest AS production

ENV ANTHROPIC_API_KEY="api-key"
ENV INFERENCE_MODEL="inference-model"
ENV PYTHONUNBUFFERED=1
ENV DEBUG=True

# Install dependencies
RUN dnf install -y \
    git \
    python3.12 \
    python3.12-pip

RUN mkdir -p /.llama /.cache
RUN chmod -R g+rw /.llama /.cache

USER 1000
WORKDIR /var/www

COPY requirements-llamastack.txt .
COPY requirements-llamastack-nodeps.txt .
COPY anthropic-run.yaml .

# Compile Python/Django application
RUN /usr/bin/python3.12 -m venv /var/www/venv
ENV PATH="/var/www/venv/bin:${PATH}"

RUN /var/www/venv/bin/python3.12 -m pip install --no-cache-dir --no-binary=all -r requirements-llamastack.txt
RUN /var/www/venv/bin/python3.12 -m pip install --no-cache-dir --no-binary=all --no-deps -r requirements-llamastack-nodeps.txt

# Launch!
ENTRYPOINT ["python3.12", "-m", "llama_stack.distribution.server.server", "--yaml-config", "/var/www/anthropic-run.yaml"]

EXPOSE 8321
