cd aks/terraform
# terraform init
# terraform apply -auto-approve
ACR_NAME=$(terraform output -raw acr_name)
RESOURCE_GROUP=$(terraform output -raw resource_group)
cd ../..
pwd
cd ..
cd spring-petclinic-admin-server
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-api-gateway
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-config-server
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-customers-service
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-discovery-server
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-vets-service
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..
cd spring-petclinic-visits-service
mvn package -PbuildAcr -DskipTests -DRESOURCE_GROUP=${RESOURCE_GROUP} -DACR_NAME=${ACR_NAME}
cd ..

# cd apps/terraform
# terraform init
# terraform apply -auto-approve