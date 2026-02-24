pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'telecom-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dir('docker') {
                        sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'
                        sh 'docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest'
                    }
                }
            }
        }
        
        stage('Test Application') {
            steps {
                script {
                    sh '''
                        docker run -d -p 5001:5000 --name telecom-test-${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        sleep 5
                        curl -f http://localhost:5001 || exit 1
                        docker stop telecom-test-${BUILD_NUMBER}
                        docker rm telecom-test-${BUILD_NUMBER}
                    '''
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                                     usernameVariable: 'DOCKER_USER', 
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker tag ${DOCKER_IMAGE}:latest $DOCKER_USER/${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker tag ${DOCKER_IMAGE}:latest $DOCKER_USER/${DOCKER_IMAGE}:latest
                            docker push $DOCKER_USER/${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push $DOCKER_USER/${DOCKER_IMAGE}:latest
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        kubectl apply -f k8s/deployment.yml
                        kubectl apply -f k8s/service.yml
                        kubectl rollout status deployment/telecom-deployment
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
