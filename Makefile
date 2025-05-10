SHELL := /usr/bin/env bash

.PHONY: bootstrap plan apply destroy lint kind kind-clean

TF       = terraform -chdir=terraform
K8S_CTX ?=
KUBECONFIG ?= $(HOME)/.kube/config

bootstrap: kind ## Create cluster (if not exists) & apply helm releases
	$(TF) init -upgrade
	$(TF) apply -auto-approve -var=kubeconfig=$(KUBECONFIG) -var=context=$(K8S_CTX)

plan:
	$(TF) plan -var=kubeconfig=$(KUBECONFIG) -var=context=$(K8S_CTX)

apply:
	$(TF) apply -var=kubeconfig=$(KUBECONFIG) -var=context=$(K8S_CTX)

destroy:
	$(TF) destroy -auto-approve -var=kubeconfig=$(KUBECONFIG) -var=context=$(K8S_CTX)

lint:
	$(TF) fmt -recursive -check
	$(TF) validate

kind:
	scripts/kind-create.sh

kind-clean:
	-kind delete cluster --name dev-env

up: kind bootstrap
