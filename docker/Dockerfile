FROM mcr.microsoft.com/openjdk/jdk:11-mariner
# takes the jar file as an argument
ARG ARTIFACT_NAME
ARG EXPOSED_PORT
# assumes the application entry port is 8080
EXPOSE ${EXPOSED_PORT}

# The application's jar file
ARG JAR_FILE=${ARTIFACT_NAME}

# Add the application's jar to the container
ADD ${JAR_FILE} app.jar

# Run the jar file
ENTRYPOINT ["java", "", "-jar","/app.jar"]