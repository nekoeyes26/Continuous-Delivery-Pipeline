pipeline {
    agent any

    environment {
        BUILD_TIMESTAMP = new Date().format("yyyyMMdd-HHmm")
        DOCKER_IMAGE = "aeonyx/calculator"
    }

    triggers {
        pollSCM('* * * * *') // polling Git setiap menit
    }    

    stages {
        stage('Debug Minikube Access') {
            steps {
                bat 'echo USERPROFILE=%USERPROFILE%'
                bat 'echo KUBECONFIG=%KUBECONFIG%'
                bat 'where minikube'
                bat 'minikube profile list'
                bat 'minikube -p staging status'
                bat 'kubectl config get-contexts'
                bat 'kubectl config use-context staging'
            }
        }

        // stage('Build') {
        //     steps {
        //         bat 'gradlew.bat build'
        //     }
        // }

        // stage('Docker Login & Build') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        //             bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
        //             bat 'docker build -t %DOCKER_IMAGE%:%BUILD_TIMESTAMP% .'
        //         }
        //     }
        // }

        // stage('Docker Push') {
        //     steps {
        //         bat 'docker push %DOCKER_IMAGE%:%BUILD_TIMESTAMP%'
        //     }
        // }

        // stage('Update deployment version') {
        //     steps {
        //         bat 'powershell -Command "(Get-Content deployment.yaml -Raw) -replace \'\\{\\{VERSION\\}\\}\', \'%BUILD_TIMESTAMP%\' | Out-File deployment.yaml -Encoding utf8"'
        //     }
        // }

        // stage('Debug deployment.yaml') {
        //     steps {
        //         bat 'type deployment.yaml'
        //     }
        // }        

        // stage('Deploy to Staging') {
        //     steps {
        //         bat 'kubectl config use-context staging'
        //         bat 'kubectl apply -f hazelcast.yaml'
        //         bat 'kubectl apply -f deployment.yaml'
        //         bat 'kubectl apply -f service.yaml'
        //     }
        // }

        // stage('Acceptance Test (Staging)') {
        //     steps {
        //         sleep time: 60, unit: 'SECONDS'
        //         bat 'acceptance-test.bat'
        //     }
        // }

        // stage('Deploy to Production') {
        //     steps {
        //         bat 'kubectl config use-context production'
        //         bat 'kubectl apply -f hazelcast.yaml'
        //         bat 'kubectl apply -f deployment.yaml'
        //         bat 'kubectl apply -f service.yaml'
        //     }
        // }

        // stage('Smoke Test (Production)') {
        //     steps {
        //         sleep time: 60, unit: 'SECONDS'
        //         bat 'smoke-test.bat'
        //     }
        // }
    }
}
