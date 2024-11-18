pipeline {
    environment {
        GIT_REPO = "https://github.com/NT548-P11-DevOps-Technology/simple-microservices-application.git"
        GIT_BRANCH = 'main'
        TRIVY_CACHE_DIR = "/var/lib/jenkins/trivy-cache"
        TMPDIR = "/var/lib/jenkins/trivy-tmp"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-mt')
    }

    agent any

    stages {
        stage('Cloning Git') {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "${env.GIT_BRANCH}"]],
                        extensions: [[$class: 'SubmoduleOption',
                                    disableSubmodules: false,
                                    parentCredentials: true,
                                    recursiveSubmodules: true,
                                    reference: '',
                                    trackingSubmodules: false]],
                        userRemoteConfigs: [[
                            url: "${env.GIT_REPO}",
                            credentialsId: 'gitToken'
                        ]]
                    ])
                }
            }
        }

        stage('Code Analysis') {
            environment {
                scannerHome = tool 'SonarScanner'
            }
            steps {
                withSonarQubeEnv('SonarQube Server') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=devop-lab02 \
                            -Dsonar.projectName=devop-lab02 \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions="**/node_modules/**,**/*.test.js,**/*.java,,**/*.ts"
                    """
                }
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Initialize') {
            steps {
                script {
                    def dockerHome = tool 'myDocker'
                    env.PATH = "${dockerHome}/bin:${env.PATH}"
                    env.DOCKER_BUILDKIT = "1"
                }
            }
        }

        stage('Docker Login') {
            steps {
                sh "echo \${DOCKERHUB_CREDENTIALS_PSW} | docker login -u \${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
            }
        }

        stage('Building image') {
            steps {
                script {
                    sh """
                        docker-compose build
                    """
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def images = [
                        'th1enlm02/class-management-fe',
                        'th1enlm02/class-management-auth-service',
                        'th1enlm02/class-management-student-service',
                        'th1enlm02/class-management-lecturer-service',
                        'th1enlm02/class-management-class-service'
                    ]

                    def totalImages = images.size()
                    def criticalImages = 0
                    def safeImages = 0

                    images.each { image ->
                        echo "======== Scanning ${image} ========"
                        sh """
                            trivy image \
                                --no-progress \
                                --ignore-unfixed \
                                ${image}:latest
                        """

                        def hasCriticalVulnerabilities = sh(
                            script: """
                                trivy image \
                                    --no-progress \
                                    --ignore-unfixed \
                                    --severity CRITICAL,HIGH \
                                    --exit-code 1 \
                                    ${image}:latest || true
                            """,
                            returnStatus: true
                        )

                        if (hasCriticalVulnerabilities == 1) {
                            criticalImages++
                            unstable(message: "Critical/High vulnerabilities found in ${image}")
                        } else {
                            safeImages++
                        }
                    }

                    withCredentials([
                        string(credentialsId: 'telegramBotToken', variable: 'TOKEN'),
                        string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')
                    ]) {
                        def messageText = """🔍 *Trivy Scan Summary*
- Total images scanned: ${totalImages}
- Images with NO Critical/High vulnerabilities: ${safeImages}
- Images with Critical/High vulnerabilities: ${criticalImages}"""

                        sh """
                            curl -X POST https://api.telegram.org/bot${TOKEN}/sendMessage \
                                -d chat_id=${CHAT_ID} \
                                -d text="${messageText}" \
                                -d parse_mode=Markdown
                        """
                    }
                }
            }
        }

        stage('Push images') {
            steps {
                script {
                    sh """
                        docker-compose push
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/NT548-P11-DevOps-Technology/assignment-lab02-kubernetes-manifests.git',
                        credentialsId: 'gitToken'
                    ]]
                ])
                script {
                    withKubeConfig(
                        caCertificate: '',
                        clusterName: 'microservices',
                        contextName: 'microservices',
                        credentialsId: 'kubernetes',
                        namespace: 'microservices',
                        restrictKubeConfigAccess: false,
                        serverUrl: 'https://192.168.110.10:6443'
                    ) {
                        sh 'kubectl apply -k .'
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
        success {
            withCredentials([string(credentialsId: 'telegramBotToken', variable: 'TOKEN'),
                             string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')]) {
                sh """
                    curl -X POST https://api.telegram.org/bot${TOKEN}/sendMessage \
                        -d chat_id=${CHAT_ID} \
                        -d text="✅ DEPLOY SUCCESS ${env.sitedeploy}"
                """
            }
        }
        failure {
            withCredentials([string(credentialsId: 'telegramBotToken', variable: 'TOKEN'),
                             string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')]) {
                sh """
                    curl -X POST https://api.telegram.org/bot${TOKEN}/sendMessage \
                        -d chat_id=${CHAT_ID} \
                        -d text="❌ DEPLOY FAILED ${env.sitedeploy}"
                """
            }
        }
    }
}