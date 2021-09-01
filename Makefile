APP_IMAGE=myorg/java-app

BUILDPACK_IMAGE=watermark-labels-buildpack
BUILDPACK_VERSION=0.0.4
BUILDPACK_CNB=watermark-labels-buildpack.cnb
REMOTE_REGISTRY= harbor.mytanzu.xyz/library

inspect: buildpack
	pack inspect $(APP_IMAGE) 
	pack inspect $(APP_IMAGE) --bom

package-buildpack: 
	@printf "`tput bold`= $@`tput sgr0`\n"
	
	pack buildpack package $(BUILDPACK_IMAGE) --config buildpack/package.toml 
	docker tag $(BUILDPACK_IMAGE)  $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker push $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)

package-cnb:
	pack buildpack package $(BUILDPACK_CNB) --config package.toml --format file

clean:
	rm $(BUILDPACK_CNB)

package-app:
	@printf "`tput bold`= $@`tput sgr0`\n"
	pack build $(APP_IMAGE) --path sampleapp

watermark-local-package-app:
	@printf "`tput bold`= $@`tput sgr0`\n"
	pack build $(APP_IMAGE) --path sampleapp --buildpack buildpack
	docker inspect $(APP_IMAGE) | grep watermark.instance
	docker inspect $(APP_IMAGE) | grep watermark.host


watermark-image-package-app: package-buildpack 
	@printf "`tput bold`= $@`tput sgr0`\n"
	pack build $(APP_IMAGE) --path sampleapp --buildpack $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker inspect $(APP_IMAGE) | grep watermark.instance
	docker inspect $(APP_IMAGE) | grep watermark.host

watermark-kpack-package-app: package-buildpack
	@printf "`tput bold`= $@`tput sgr0`\n"

	kubectl apply -f kpack/01-store.yml		
	kubectl wait --for=condition=ready --timeout=30s  clusterstore/my-customized-clusterstore
	kubectl get ClusterStore  my-customized-clusterstore

	kubectl apply -f kpack/02-builder.yml
	kubectl wait --for=condition=ready --timeout=30s -n kpack Builder/my-watermark-springboot-builder  
	kubectl get Builder -n kpack my-watermark-springboot-builder

	kubectl apply -f kpack/03-image.yml	
	kubectl wait --for=condition=ready --timeout=90s -n kpack Image/my-watermark-sampleapp-image
	kubectl get images -n kpack my-watermark-sampleapp-image

	docker pull harbor.mytanzu.xyz/library/my-watermark-sampleapp
	docker inspect harbor.mytanzu.xyz/library/my-watermark-sampleapp | grep watermark.instance
	docker inspect harbor.mytanzu.xyz/library/my-watermark-sampleapp | grep watermark.host

kpack-logs:
	./kpack_logs.sh my-watermark-sampleapp-image kpack

clean-kpack:
	@printf "`tput bold`= $@`tput sgr0`\n"
	kubectl delete -f kpack
