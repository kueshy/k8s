// // pipeline {
// //     agent any
// //
// //     environment {
// //         DOCKER_IMAGE = "codedev001/spring-boot-demo"
// //         DOCKER_TAG = "${BUILD_NUMBER}"
// //         DOCKER_CREDENTIALS = 'dockerhub-credentials'
// //         K8S_NAMESPACE = 'default'
// //     }
// //
// //     stages {
// //         stage('Checkout') {
// //             steps {
// //                 git branch: 'main',
// //                     url: 'https://github.com/yourusername/spring-boot-demo.git'
// //             }
// //         }
// //
// //         stage('Build with Maven') {
// //             steps {
// //                 sh 'mvn clean package -DskipTests'
// //             }
// //         }
// //
// //         stage('Run Tests') {
// //             steps {
// //                 sh 'mvn test'
// //             }
// //             post {
// //                 always {
// //                     junit '**/target/surefire-reports/*.xml'
// //                 }
// //             }
// //         }
// //
// //         stage('Build Docker Image') {
// //             steps {
// //                 script {
// //                     docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
// //                     docker.build("${DOCKER_IMAGE}:latest")
// //                 }
// //             }
// //         }
// //
// //         stage('Push to Docker Hub') {
// //             steps {
// //                 script {
// //                     docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS) {
// //                         docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
// //                         docker.image("${DOCKER_IMAGE}:latest").push()
// //                     }
// //                 }
// //             }
// //         }
// //
// //         stage('Deploy to Kubernetes') {
// //             steps {
// //                 kubernetesDeploy(
// //                     configs: 'k8s/deployment.yaml,k8s/service.yaml',
// //                     kubeconfigId: 'kubernetes-credentials',  // Your K8s creds ID
// //                     enableConfigSubstitution: true
// //                 )
// //             }
// //         }
// //
// //         stage('Deploy to Kubernetes') {
// //             steps {
// //                 script {
// //                     // Update deployment with new image
// //                     sh """
// //                         kubectl set image deployment/spring-boot-demo \
// //                             demo=${DOCKER_IMAGE}:${DOCKER_TAG} \
// //                             -n ${K8S_NAMESPACE}
// //                     """
// //
// //                     // Wait for rollout to complete
// //                     sh """
// //                         kubectl rollout status deployment/spring-boot-demo \
// //                             -n ${K8S_NAMESPACE}
// //                     """
// //                 }
// //             }
// //         }
// //
// //         stage('Rollback on Failure') {
// //             when {
// //                 expression { currentBuild.result == 'FAILURE' }
// //             }
// //             steps {
// //                 script {
// //                     sh 'kubectl rollout undo deployment/spring-boot-demo -n default'
// //                 }
// //             }
// //         }
// //
// //         stage('Verify Deployment') {
// //             steps {
// //                 script {
// //                     sh """
// //                         kubectl get pods -n ${K8S_NAMESPACE} -l app=spring-boot-demo
// //                         kubectl get svc -n ${K8S_NAMESPACE} spring-boot-demo-service
// //                     """
// //                 }
// //             }
// //         }
// //     }
// //
// //     post {
// //         success {
// //             echo 'Deployment successful!'
// //         }
// //         failure {
// //             echo 'Deployment failed!'
// //         }
// //         always {
// //             // Clean up Docker images
// //             sh 'docker image prune -f'
// //         }
// //     }
// // }
//
// // ===== Jenkinsfile for Monolithic Application =====
//
// pipeline {
//     agent any
//     tools {
//         maven 'maven3'
//         jdk 'JDK17'
//     }
//
//     environment {
//         // Application info
//         APP_NAME = 'ecommerce-monolith'
//
//         // Docker configuration
//         DOCKER_REGISTRY = 'docker.io'
//         DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
//         DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}"
//
//         // Maven configuration
//         MAVEN_OPTS = '-Xmx2048m -Xms1024m'
//         JAVA_HOME = tool name: 'JDK17', type: 'jdk'
//
//         // SonarQube configuration
//         SONAR_HOST_URL = 'http://sonarqube:9000'
//         SONAR_CREDENTIALS_ID = 'sonarqube-token'
//
//         // Kubernetes configuration
//         K8S_NAMESPACE = 'production'
//         K8S_CREDENTIALS_ID = 'kubernetes-config'
//
//         // Database configuration for tests
//         TEST_DB_URL = 'jdbc:h2:mem:testdb'
//
//         // Notification
//         SLACK_CHANNEL = '#devops-alerts'
//         SLACK_CREDENTIALS_ID = 'slack-webhook'
//
//         // Version management
//         VERSION = "${env.BUILD_NUMBER}"
//         GIT_COMMIT_SHORT = sh(
//             script: "git rev-parse --short HEAD",
//             returnStdout: true
//         ).trim()
//         IMAGE_TAG = "${VERSION}-${GIT_COMMIT_SHORT}"
//     }
//
//     parameters {
//         choice(
//             name: 'ENVIRONMENT',
//             choices: ['dev', 'staging', 'production'],
//             description: 'Target deployment environment'
//         )
//         booleanParam(
//             name: 'RUN_INTEGRATION_TESTS',
//             defaultValue: true,
//             description: 'Run integration tests'
//         )
//         booleanParam(
//             name: 'RUN_PERFORMANCE_TESTS',
//             defaultValue: false,
//             description: 'Run performance tests'
//         )
//         booleanParam(
//             name: 'DEPLOY_TO_K8S',
//             defaultValue: true,
//             description: 'Deploy to Kubernetes cluster'
//         )
//         booleanParam(
//             name: 'RUN_SECURITY_SCAN',
//             defaultValue: true,
//             description: 'Run security vulnerability scan'
//         )
//     }
//
//     triggers {
//         pollSCM('H/5 * * * *')
//         githubPush()
//     }
//
//     options {
//         buildDiscarder(logRotator(numToKeepStr: '10'))
//         timeout(time: 1, unit: 'HOURS')
//         disableConcurrentBuilds()
//         timestamps()
//     }
//
//     stages {
//         stage('🔄 Checkout') {
//             steps {
//                 script {
//                     echo "Checking out code from Git..."
//                     checkout scm
//
//                     sh '''
//                         echo "============================================"
//                         echo "Build Information"
//                         echo "============================================"
//                         echo "Application: ${APP_NAME}"
//                         echo "Branch: ${GIT_BRANCH}"
//                         echo "Commit: ${GIT_COMMIT_SHORT}"
//                         echo "Build Number: ${BUILD_NUMBER}"
//                         echo "Image Tag: ${IMAGE_TAG}"
//                         echo "Environment: ${ENVIRONMENT}"
//                         echo "============================================"
//                     '''
//                 }
//             }
//         }
//
// //         stage('🔍 Code Analysis') {
// //             parallel {
// //                 stage('Checkstyle') {
// //                     steps {
// //                         script {
// //                             echo "Running Checkstyle..."
// //                             sh 'mvn checkstyle:check -B'
// //                         }
// //                     }
// //                 }
// //
// //                 stage('PMD') {
// //                     steps {
// //                         script {
// //                             echo "Running PMD..."
// //                             sh 'mvn pmd:check -B'
// //                         }
// //                     }
// //                 }
// //
// //                 stage('SpotBugs') {
// //                     steps {
// //                         script {
// //                             echo "Running SpotBugs..."
// //                             sh 'mvn spotbugs:check -B'
// //                         }
// //                     }
// //                 }
// //             }
// //         }
//
//         stage('🔨 Build') {
//             steps {
//                 script {
//                     echo "Building application..."
//                     sh '''
//                         mvn clean compile \
//                             -DskipTests=true \
//                             -B -V
//                     '''
//                 }
//             }
//         }
//
// //         stage('🧪 Unit Tests') {
// //             steps {
// //                 script {
// //                     echo "Running unit tests..."
// //                     sh '''
// //                         mvn test \
// //                             -Dtest=*Test \
// //                             -B
// //                     '''
// //                 }
// //             }
// //             post {
// //                 always {
// //                     junit 'target/surefire-reports/*.xml'
// //
// //                     publishHTML(target: [
// //                         reportDir: 'target/surefire-reports',
// //                         reportFiles: '*.html',
// //                         reportName: 'Unit Test Report'
// //                     ])
// //                 }
// //             }
// //         }
// //
// //         stage('🔗 Integration Tests') {
// //             when {
// //                 expression { params.RUN_INTEGRATION_TESTS }
// //             }
// //             steps {
// //                 script {
// //                     echo "Starting test database..."
// //
// //                     sh '''
// //                         # Start PostgreSQL for integration tests
// //                         docker run -d \
// //                             --name test-postgres \
// //                             -e POSTGRES_DB=testdb \
// //                             -e POSTGRES_USER=testuser \
// //                             -e POSTGRES_PASSWORD=testpass \
// //                             -p 5433:5432 \
// //                             postgres:15-alpine
// //
// //                         # Wait for database to be ready
// //                         sleep 10
// //                     '''
// //
// //                     try {
// //                         sh '''
// //                             mvn verify \
// //                                 -Dtest=*IT \
// //                                 -DskipUnitTests=true \
// //                                 -Dspring.datasource.url=jdbc:postgresql://localhost:5433/testdb \
// //                                 -Dspring.datasource.username=testuser \
// //                                 -Dspring.datasource.password=testpass \
// //                                 -B
// //                         '''
// //                     } finally {
// //                         sh 'docker stop test-postgres && docker rm test-postgres'
// //                     }
// //                 }
// //             }
// //             post {
// //                 always {
// //                     junit 'target/failsafe-reports/*.xml'
// //                 }
// //             }
// //         }
//
//         stage('📊 Code Coverage') {
//             steps {
//                 script {
//                     echo "Generating code coverage report..."
//                     sh 'mvn jacoco:report'
//                 }
//             }
//             post {
//                 always {
//                     jacoco(
//                         execPattern: '**/target/jacoco.exec',
//                         classPattern: '**/target/classes',
//                         sourcePattern: '**/src/main/java',
//                         minimumLineCoverage: '70',
//                         minimumBranchCoverage: '60'
//                     )
//                 }
//             }
//         }
//
//         stage('🔍 SonarQube Analysis') {
//             steps {
//                 script {
//                     echo "Running SonarQube analysis..."
//
//                     withSonarQubeEnv('SonarQube') {
//                         sh '''
//                             mvn sonar:sonar \
//                                 -Dsonar.projectKey=${APP_NAME} \
//                                 -Dsonar.projectName="${APP_NAME}" \
//                                 -Dsonar.host.url=${SONAR_HOST_URL} \
//                                 -Dsonar.java.coveragePlugin=jacoco \
//                                 -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
//                         '''
//                     }
//                 }
//             }
//         }
//
//         stage('🚦 Quality Gate') {
//             steps {
//                 script {
//                     echo "Waiting for SonarQube Quality Gate..."
//
//                     timeout(time: 5, unit: 'MINUTES') {
//                         def qg = waitForQualityGate()
//                         if (qg.status != 'OK') {
//                             error "Quality Gate failed: ${qg.status}"
//                         }
//                         echo "✅ Quality Gate passed!"
//                     }
//                 }
//             }
//         }
//
//         stage('🔐 Security Scan') {
//             when {
//                 expression { params.RUN_SECURITY_SCAN }
//             }
//             parallel {
//                 stage('Dependency Check') {
//                     steps {
//                         script {
//                             echo "Checking for vulnerable dependencies..."
//                             sh '''
//                                 mvn dependency-check:check \
//                                     -DfailBuildOnCVSS=7 \
//                                     -B
//                             '''
//                         }
//                     }
//                     post {
//                         always {
//                             publishHTML(target: [
//                                 reportDir: 'target',
//                                 reportFiles: 'dependency-check-report.html',
//                                 reportName: 'OWASP Dependency Check Report'
//                             ])
//                         }
//                     }
//                 }
//
//                 stage('SAST Scan') {
//                     steps {
//                         script {
//                             echo "Running SAST scan..."
//                             // Add your SAST tool here (e.g., Snyk, Checkmarx)
//                         }
//                     }
//                 }
//             }
//         }
//
//         stage('📦 Package') {
//             steps {
//                 script {
//                     echo "Packaging application..."
//                     sh '''
//                         mvn package \
//                             -DskipTests=true \
//                             -B
//                     '''
//                 }
//             }
//             post {
//                 success {
//                     archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
//                 }
//             }
//         }
//
//         stage('🐳 Build Docker Image') {
//             steps {
//                 script {
//                     echo "Building Docker image..."
//
//                     docker.build(
//                         "${DOCKER_IMAGE}:${IMAGE_TAG}",
//                         "--build-arg JAR_FILE=target/${APP_NAME}.jar ."
//                     )
//
//                     // Tag as latest for the environment
//                     sh "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:${ENVIRONMENT}-latest"
//                 }
//             }
//         }
//
//         stage('🔒 Image Security Scan') {
//             when {
//                 expression { params.RUN_SECURITY_SCAN }
//             }
//             steps {
//                 script {
//                     echo "Scanning Docker image for vulnerabilities..."
//
//                     sh """
//                         trivy image \
//                             --severity HIGH,CRITICAL \
//                             --format json \
//                             --output target/trivy-report.json \
//                             ${DOCKER_IMAGE}:${IMAGE_TAG}
//                     """
//
//                     // Check if critical vulnerabilities found
//                     def trivyReport = readJSON file: 'target/trivy-report.json'
//                     def criticalCount = 0
//
//                     if (trivyReport.Results) {
//                         trivyReport.Results.each { result ->
//                             if (result.Vulnerabilities) {
//                                 criticalCount += result.Vulnerabilities.findAll {
//                                     it.Severity == 'CRITICAL'
//                                 }.size()
//                             }
//                         }
//                     }
//
//                     echo "Found ${criticalCount} critical vulnerabilities"
//
//                     if (criticalCount > 0) {
//                         error "Found ${criticalCount} critical vulnerabilities in Docker image"
//                     }
//                 }
//             }
//             post {
//                 always {
//                     publishHTML(target: [
//                         reportDir: 'target',
//                         reportFiles: 'trivy-report.json',
//                         reportName: 'Trivy Security Report'
//                     ])
//                 }
//             }
//         }
//
//         stage('📤 Push to Registry') {
//             when {
//                 anyOf {
//                     branch 'main'
//                     branch 'develop'
//                 }
//             }
//             steps {
//                 script {
//                     echo "Pushing Docker image to registry..."
//
//                     docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
//                         sh """
//                             docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
//                             docker push ${DOCKER_IMAGE}:${ENVIRONMENT}-latest
//                         """
//                     }
//
//                     echo "✅ Image pushed: ${DOCKER_IMAGE}:${IMAGE_TAG}"
//                 }
//             }
//         }
//
//         stage('🚀 Deploy to Kubernetes') {
//             when {
//                 allOf {
//                     anyOf {
//                         branch 'main'
//                         branch 'develop'
//                     }
//                     expression { params.DEPLOY_TO_K8S }
//                 }
//             }
//             steps {
//                 script {
//                     echo "Deploying to Kubernetes ${params.ENVIRONMENT} environment..."
//
//                     withKubeConfig([credentialsId: K8S_CREDENTIALS_ID]) {
//                         // Update deployment with new image
//                         sh """
//                             kubectl set image deployment/${APP_NAME} \
//                                 ${APP_NAME}=${DOCKER_IMAGE}:${IMAGE_TAG} \
//                                 -n ${K8S_NAMESPACE}
//
//                             # Verify rollout
//                             kubectl rollout status deployment/${APP_NAME} \
//                                 -n ${K8S_NAMESPACE} \
//                                 --timeout=5m
//                         """
//
//                         // Get deployment info
//                         sh """
//                             echo "Deployment status:"
//                             kubectl get deployment ${APP_NAME} -n ${K8S_NAMESPACE}
//
//                             echo "\\nPods:"
//                             kubectl get pods -l app=${APP_NAME} -n ${K8S_NAMESPACE}
//
//                             echo "\\nServices:"
//                             kubectl get svc ${APP_NAME} -n ${K8S_NAMESPACE}
//                         """
//                     }
//                 }
//             }
//         }
//
//         stage('💨 Smoke Tests') {
//             when {
//                 allOf {
//                     anyOf {
//                         branch 'main'
//                         branch 'develop'
//                     }
//                     expression { params.DEPLOY_TO_K8S }
//                 }
//             }
//             steps {
//                 script {
//                     echo "Running smoke tests..."
//
//                     // Wait for pods to be ready
//                     sleep(time: 30, unit: 'SECONDS')
//
//                     sh '''
//                         # Get service URL
//                         SERVICE_URL=$(kubectl get svc ${APP_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
//
//                         if [ -z "$SERVICE_URL" ]; then
//                             SERVICE_URL="localhost:8080"
//                         fi
//
//                         # Test health endpoint
//                         echo "Testing health endpoint..."
//                         curl -f http://${SERVICE_URL}/actuator/health || exit 1
//
//                         # Test metrics endpoint
//                         echo "Testing metrics endpoint..."
//                         curl -f http://${SERVICE_URL}/actuator/metrics || exit 1
//
//                         # Test API docs
//                         echo "Testing API docs..."
//                         curl -f http://${SERVICE_URL}/swagger-ui.html || exit 1
//
//                         echo "✅ All smoke tests passed!"
//                     '''
//                 }
//             }
//         }
//
//         stage('⚡ Performance Tests') {
//             when {
//                 expression { params.RUN_PERFORMANCE_TESTS }
//             }
//             steps {
//                 script {
//                     echo "Running performance tests with JMeter..."
//
//                     sh '''
//                         # Run JMeter tests
//                         jmeter -n \
//                             -t tests/performance/load-test.jmx \
//                             -l target/jmeter-results.jtl \
//                             -e -o target/jmeter-report \
//                             -Jthreads=50 \
//                             -Jrampup=10 \
//                             -Jduration=300
//                     '''
//                 }
//             }
//             post {
//                 always {
//                     perfReport(
//                         sourceDataFiles: 'target/jmeter-results.jtl',
//                         errorFailedThreshold: 5,
//                         errorUnstableThreshold: 2,
//                         relativeFailedThresholdPositive: 20,
//                         relativeUnstableThresholdPositive: 10
//                     )
//
//                     publishHTML(target: [
//                         reportDir: 'target/jmeter-report',
//                         reportFiles: 'index.html',
//                         reportName: 'JMeter Performance Report'
//                     ])
//                 }
//             }
//         }
//
//         stage('📝 Generate Documentation') {
//             steps {
//                 script {
//                     echo "Generating project documentation..."
//
//                     sh '''
//                         # Generate JavaDoc
//                         mvn javadoc:javadoc
//
//                         # Generate site
//                         mvn site:site
//                     '''
//                 }
//             }
//             post {
//                 always {
//                     publishHTML(target: [
//                         reportDir: 'target/site',
//                         reportFiles: 'index.html',
//                         reportName: 'Project Documentation'
//                     ])
//                 }
//             }
//         }
//     }
//
//     post {
//         always {
//             script {
//                 echo "Pipeline execution completed"
//
//                 // Clean workspace
//                 cleanWs()
//             }
//         }
//
//         success {
//             script {
//                 echo "✅ Build successful!"
//
//                 // Send email notification
//                 emailext(
//                     subject: "✅ Build Successful: ${APP_NAME} #${BUILD_NUMBER}",
//                     body: """
//                         <h2>Build Successful</h2>
//                         <p>
//                             <strong>Project:</strong> ${APP_NAME}<br>
//                             <strong>Build:</strong> #${BUILD_NUMBER}<br>
//                             <strong>Branch:</strong> ${GIT_BRANCH}<br>
//                             <strong>Environment:</strong> ${params.ENVIRONMENT}<br>
//                             <strong>Image:</strong> ${DOCKER_IMAGE}:${IMAGE_TAG}
//                         </p>
//                         <p><a href="${BUILD_URL}">View Build Details</a></p>
//                     """,
//                     to: 'eliasemonyi6@gmail.com',
//                     mimeType: 'text/html'
//                 )
//             }
//         }
//
//         failure {
//             script {
//                 echo "❌ Build failed!"
//
//                 emailext(
//                     subject: "❌ Build Failed: ${APP_NAME} #${BUILD_NUMBER}",
//                     body: """
//                         <h2>Build Failed</h2>
//                         <p>
//                             <strong>Project:</strong> ${APP_NAME}<br>
//                             <strong>Build:</strong> #${BUILD_NUMBER}<br>
//                             <strong>Branch:</strong> ${GIT_BRANCH}<br>
//                             <strong>Failed Stage:</strong> ${env.STAGE_NAME}
//                         </p>
//                         <p><a href="${BUILD_URL}console">View Console Output</a></p>
//                     """,
//                     to: 'eliasemonyi6@gmail.com',
//                     mimeType: 'text/html'
//                 )
//             }
//         }
//
//         unstable {
//             script {
//                 echo "⚠️  Build unstable!"
//             }
//         }
//     }
// }

pipeline {
    agent any
    tools {
        maven 'maven3'
        jdk 'JDK17'
        docker 'docker'
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/kueshy/k8s.git', branch: 'main'
            }
        }
        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests -B'  // bat for Windows
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                script {
                    def imageTag = "1.0.${env.BUILD_NUMBER}"
                    sh "docker build -t codedev001/k8s-demo:${imageTag} ."
                    withDockerRegistry([credentialsId: 'docker-hub-creds', url: '']) {
                        sh "docker push codedev001/k8s-demo:${imageTag}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                kubernetesDeploy(
                    configs: 'k8s/deployment.yaml,k8s/service.yaml',
                    kubeconfigId: 'k8s-kubeconfig-file',
                    enableConfigSubstitution: true
                )
            }
        }
    }
}