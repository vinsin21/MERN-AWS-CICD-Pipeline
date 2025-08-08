# Stage 1: Build the React application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
# This creates a 'dist' or 'build' folder with your static files
RUN npm run build

# Stage 2: Serve the application using Nginx
FROM nginx:stable-alpine
# Copy the static files from the 'builder' stage
COPY --from=builder /app/dist /usr/share/nginx/html
# If your app is a Single Page Application (SPA), you might need a custom nginx.conf
# to handle routing. For now, this is a great start.
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]