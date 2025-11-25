# Base image for Node.js
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy dependency files first to leverage Docker's build cache
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD [ "npm", "start" ]
