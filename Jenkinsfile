pipeline {
    agent any

    environment {
        BUILD_TIMESTAMP = new Date().format("yyyyMMdd-HHmm")
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {
        stage("Compile") {
            steps {
                bat 'gradlew.bat compileJava'
            }
        }

        stage("Unit test") {
            steps {
                bat 'gradlew.bat test'
            }
        }

        stage("Code coverage") {
            steps {
                bat 'gradlew.bat jacocoTestReport'
                bat 'gradlew.bat jacocoTestCoverageVerification'
            }
        }

        stage("Static code analysis") {
            steps {
                bat 'gradlew.bat checkstyleMain'
            }
        }

        stage("Package") {
            steps {
                bat 'gradlew.bat build'
            }
        }

        stage("Docker build") {
            steps {
                bat 'docker build -t aeonyx/calculator:%BUILD_TIMESTAMP% .'
            }
        }

        stage("Docker push") {
            steps {
                bat 'docker push aeonyx/calculator:%BUILD_TIMESTAMP%'
            }
        }

        stage("Update version") {
            steps {
                bat 'powershell -Command "(Get-Content deployment.yaml) -replace \'\\{\\{VERSION\\}\\}\', \'%BUILD_TIMESTAMP%\' | Set-Content deployment.yaml"'
            }
        }

        stage("Deploy to staging") {
            steps {
                bat 'kubectl config use-context staging'
                bat 'kubectl apply -f hazelcast.yaml'
                bat 'kubectl apply -f deployment.yaml'
                bat 'kubectl apply -f service.yaml'
            }
        }

        stage("Acceptance test") {
            steps {
                sleep time: 60, unit: 'SECONDS'
                bat 'acceptance-test.bat'
            }
        }

        stage("Release to production") {
            steps {
                bat 'kubectl config use-context production'
                bat 'kubectl apply -f hazelcast.yaml'
                bat 'kubectl apply -f deployment.yaml'
                bat 'kubectl apply -f service.yaml'
            }
        }

        stage("Smoke test") {
            steps {
                sleep time: 60, unit: 'SECONDS'
                bat 'smoke-test.bat'
            }
        }
    }
}
