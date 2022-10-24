pipeline {
    agent any
        environment {
            HOME = '.'
            /* demo horizontal movement */
            SONAR_SERVICE_NAME = [ sh (returnStdout: true, script: 'echo ${JOB_NAME} | sed -r "s/\\//\\&branch\\=/g"').trim() ]
        }
    stages {
        stage('Test') {
            agent {
                docker {
                    image "node:${NODE_VERSION}-alpine"
                }
            }
            steps {
                sh 'npm i'
                sh 'npm run test:ci-coverage'
                stash includes: 'coverage/lcov.info', name: 'coverage-info'
            }
        }
        stage('SonarQube') {
            environment {
                NODE_PATH = '/usr/lib/node_modules'
                scannerHome = tool 'SonarQubeScanner'
            }
            agent { label 'linux2' }
            steps {
                withSonarQubeEnv('SonarQube Central') {
                    unstash 'coverage-info'
                    sh "${scannerHome}/bin/sonar-scanner -X"
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build Develop For EKS') {
            agent {
                docker {
                    image "node:${NODE_VERSION}-alpine"
                }
            }
            steps {
                sh 'npm i'
                sh './scripts/links.sh k8s'
                sh 'npm run build'
                sh 'rm -rf build_k8s'
                sh 'mv build build_k8s'
                stash includes: 'build_k8s/**', name: 'build_k8s'
                archiveArtifacts(artifacts: 'build_k8s/**', onlyIfSuccessful: true)
            }
        }
        stage('Deploy Develop to EKS') {
            agent { label 'linux2' }
            environment {
                HOME = '/home/ec2-user'
            }
            steps {
                unstash 'build_k8s'
                sh "aws s3 sync --delete build_k8s/ s3://${K8S_BUCKET_BASENAME}-develop-frontend"
                sh "aws s3 cp s3://${K8S_BUCKET_BASENAME}-develop-frontend/locales/en/translation.json s3://${K8S_BUCKET_BASENAME}-develop-frontend/locales/en/translation.json --metadata-directive REPLACE --cache-control max-age=0,no-cache,no-store,must-revalidate --content-type application/json"
                sh "aws cloudfront create-invalidation --distribution-id ${K8S_DISTRIBUTION_ID} --paths /index.html /locales/en/translation.json"
            }
        }
    }
}
