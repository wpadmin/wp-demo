# Makefile для WordPress сайта

# Поднять сайт
up:
	docker-compose up -d
	@echo "WordPress запущен на http://localhost:8080"

# Остановить сайт
down:
	docker-compose down
	@echo "WordPress остановлен"

# Перезапустить
restart: down up

# Показать логи
logs:
	docker-compose logs -f

# Удалить всё (включая данные!)
clean:
	docker-compose down -v
	@echo "⚠️  Все данные удалены!"

# Проверить статус
status:
	docker-compose ps