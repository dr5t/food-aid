# Use PHP Apache image
FROM php:8.1-apache

# Install dependencies for Python and SQL integration
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libmariadb-dev

# Copy backend files
COPY backend/ /var/www/html/

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]
