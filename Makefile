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
	@echo "  deploy            deploy example to registered 'docker_dev' for Nextcloud Last"
	@echo "  deploy27          deploy example to registered 'docker_dev' for Nextcloud 27"
	@echo "  "
	@echo "  run               install AIImageGeneratorBot for Nextcloud Last"
	@echo "  run27             install AIImageGeneratorBot for Nextcloud 27"
	@echo "  "
	@echo "  For development of this example use PyCharm run configurations. Development is always set for last Nextcloud."
	@echo "  First run 'AIImageGeneratorBot' and then 'make registerXX', after that you can use/debug/develop it and easy test."
	@echo "  "
	@echo "  register          perform registration of running 'AIImageGeneratorBot' into the 'manual_install' deploy daemon."
	@echo "  register27        perform registration of running 'AIImageGeneratorBot' into the 'manual_install' deploy daemon."

.PHONY: build-push
build-push:
	docker login ghcr.io
	docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ghcr.io/cloud-py-api/ai_image_generator_bot:2.0.0 --tag ghcr.io/cloud-py-api/ai_image_generator_bot:latest .

.PHONY: deploy
deploy:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:deploy ai_image_generator_bot \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: deploy27
deploy27:
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:deploy ai_image_generator_bot \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: run
run:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: run27
run27:
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot --force-scopes \
		--info-xml https://raw.githubusercontent.com/cloud-py-api/ai_image_generator_bot/main/appinfo/info.xml

.PHONY: register
register:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot manual_install --json-info \
  "{\"appid\":\"ai_image_generator_bot\",\"name\":\"AIImageGeneratorBot\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9080,\"scopes\":[\"TALK\", \"TALK_BOT\", \"FILES\", \"FILES_SHARING\"],\"system_app\":1}" \
  --force-scopes --wait-finish

.PHONY: register27
register27:
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:unregister ai_image_generator_bot --silent --force || true
	docker exec master-stable27-1 sudo -u www-data php occ app_api:app:register ai_image_generator_bot manual_install --json-info \
  "{\"appid\":\"ai_image_generator_bot\",\"name\":\"AIImageGeneratorBot\",\"daemon_config_name\":\"manual_install\",\"version\":\"1.0.0\",\"secret\":\"12345\",\"port\":9080,\"scopes\":[\"TALK\", \"TALK_BOT\", \"FILES\", \"FILES_SHARING\"],\"system_app\":1}" \
  --force-scopes --wait-finish
