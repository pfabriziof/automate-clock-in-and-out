# Dockerfile
FROM --platform=${BUILDPLATFORM} public.ecr.aws/docker/library/python:3.12-slim AS builder

# Upgrade pip and install Poetry and build essentials
RUN pip install --upgrade pip && \
    apt-get update && apt-get install -y --no-install-recommends build-essential && \
    pip install --no-cache-dir poetry==2.1.3 && \
    rm -rf /var/lib/apt/lists/* /root/.cache/pip

WORKDIR /app/builder

# Copy only what's necessary to install dependencies first
COPY pyproject.toml poetry.lock ./

# Configure and install only main dependencies to a target directory
RUN poetry config virtualenvs.create false && \
    poetry config installer.max-workers 10 && \
    poetry install --only main --no-root --no-directory

# Final minimal Lambda image
FROM --platform=${BUILDPLATFORM} public.ecr.aws/lambda/python:3.12

WORKDIR ${LAMBDA_TASK_ROOT}

# Copy installed packages from builder stage
# Python packages are installed in /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/lib/python3.12/site-packages/ ./

# Copy source code
COPY main.py ./

CMD [ "main.lambda_handler" ]