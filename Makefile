.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Welcome to AIImageGeneratorBot example. Please use \`make <target>\` where <target> is one of"
	@echo " "
	@echo "  Next commands are only for dev environment with nextcloud-docker-dev!"
	@echo "  They should run from the host you are developing on(with activated venv) and not in the container with Nextcloud!"
	@echo "  "
	@echo "  build-push        build image and upload to ghcr.io"
	@echo "  "
	@echo "  run27             install AIImageGeneratorBot for Nextcloud 27"
	@echo "  run               install AIImageGeneratorBot for Nextcloud 28"
	@echo "  run               install AIImageGeneratorBot for Nextcloud 29"
	@echo "  "
	@echo "  For development of this example use PyCharm run configurations. Development is always set for last Nextcloud."
	@echo "  First run 'AIImageGeneratorBot' and then 'make registerXX', after that you can use/debug/develop it and easy test."
	@echo "  "
	@echo "  register27        perform registration of running 'AIImageGeneratorBot' into the 'manual_install' deploy daemon."
	@echo "  register28        perform registration of running 'AIImageGeneratorBot' into the 'manual_install' deploy daemon."
	@echo "  register29        perform registration of running 'AIImageGeneratorBot' into the 'manual_install' deploy daemon."

.PHONY: build-push
build-push:
	docker login ghcr.io
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ghcr.io/cloud-py-api/ai_image_generator_bot:2.1.0 .

.PHONY: build-push-last
build-push-last:
	docker login ghcr.io
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ghcr.io/cloud-py-api/ai_image_generator_bot:latest .

.PHONY: run27
run27:
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: run28
run28:
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: run29
run29:
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: register27
register27:
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot manual_install --json-info \
  "{\"id\":\"ai_image_generator_bot\",\"name\":\"AIImageGeneratorBot\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9080,\"scopes\":[\"TALK\", \"TALK_BOT\", \"FILES\", \"FILES_SHARING\"],\"system\":1}" \
  --force-scopes --wait-finish

.PHONY: register28
register28:
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable28-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot manual_install --json-info \
  "{\"id\":\"ai_image_generator_bot\",\"name\":\"AIImageGeneratorBot\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9080,\"scopes\":[\"TALK\", \"TALK_BOT\", \"FILES\", \"FILES_SHARING\"],\"system\":1}" \
  --force-scopes --wait-finish

.PHONY: register29
register29:
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable29-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot manual_install --json-info \
  "{\"id\":\"ai_image_generator_bot\",\"name\":\"AIImageGeneratorBot\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9080,\"scopes\":[\"TALK\", \"TALK_BOT\", \"FILES\", \"FILES_SHARING\"],\"system\":1}" \
  --force-scopes --wait-finish
