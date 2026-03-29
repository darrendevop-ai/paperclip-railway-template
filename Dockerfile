FROM node:20-slim

# Install gosu and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gosu curl gnupg && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r paperclip && useradd -r -g paperclip -m -d /home/paperclip -s /bin/bash paperclip

# Create the paperclip home directory
RUN mkdir -p /paperclip && chown -R paperclip:paperclip /paperclip

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install --omit=dev

# Install Gemini CLI globally
RUN npm install -g @google/gemini-cli

# Copy application code
COPY . .

# Give ownership to non-root user
RUN mkdir -p /home/paperclip/.gemini && \
    chown -R paperclip:paperclip /app /home/paperclip

# Copy and set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set Gemini API key
ENV GEMINI_API_KEY=""
ENV PORT=3100
EXPOSE 3100

RUN sed -i 's/\r//' /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
