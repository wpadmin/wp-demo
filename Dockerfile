FROM wordpress:latest

# Устанавливаем WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Скрипт автонастройки
RUN echo '#!/bin/bash\n\
    # Запускаем оригинальный entrypoint\n\
    docker-entrypoint.sh "$@" &\n\
    sleep 15\n\
    \n\
    # Проверяем что WordPress уже не настроен\n\
    if [ ! -f /var/www/html/.setup-done ]; then\n\
    echo "Настраиваем WordPress..."\n\
    \n\
    # Ждем готовности\n\
    while ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; do\n\
    wp core install --path=/var/www/html --url=http://localhost:8000 --title="Demo Store" --admin_user=admin --admin_password=12345 --admin_email=admin@example.com --allow-root 2>/dev/null || true\n\
    sleep 5\n\
    done\n\
    \n\
    # Устанавливаем WooCommerce\n\
    wp plugin install woocommerce --activate --allow-root\n\
    wp plugin install wordpress-importer --activate --allow-root\n\
    \n\
    # Демо данные\n\
    curl -s -o /tmp/sample.xml https://raw.githubusercontent.com/woocommerce/woocommerce/trunk/sample-data/sample_products.xml\n\
    wp import /tmp/sample.xml --authors=create --allow-root 2>/dev/null || true\n\
    \n\
    # Базовые настройки\n\
    wp theme install storefront --activate --allow-root\n\
    wp wc tool run install_pages --allow-root 2>/dev/null || true\n\
    wp rewrite structure "/%postname%/" --allow-root\n\
    \n\
    # Исправляем права\n\
    chown -R www-data:www-data /var/www/html\n\
    \n\
    touch /var/www/html/.setup-done\n\
    echo "Готово! admin/12345 на http://localhost:8000/wp-admin"\n\
    fi\n\
    \n\
    wait' > /setup.sh && chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]
CMD ["apache2-foreground"]