pipeline {
  agent any
  parameters {
    string(name: 'Container', defaultValue: 'todoapp', description: 'Container name')
    string(name: 'Image', defaultValue: 'todoapp:latest', description: 'Image name and tag')
    string(name: 'Repo', defaultValue: 'tutug', description: 'Reporitory url')
  }
  stages {  
    stage('Cloning Git') {
      steps {
        checkout scm
      }
    }
        
    stage('Install dependencie') {
      steps {
        sh 'npm install'
      }
    }
     
    stage('Test') {
      steps {
         sh 'npm test'
      }
    }

    stage('Remove older image') {
      steps {
        sh "docker rmi -f ${params.Repo}/${params.Image} || true"
      }
    }

    stage('Build docker image') {
      steps {
        echo env.JWT_SECRET
        sh """docker build \
          --build-arg JWT_SECRET=${env.JWT_SECRET} \
          --build-arg PORT=${env.PORT || 3005} \
          --build-arg API_URL=${env.API_URL || "http://localhost:3005/api"} \
          -t ${params.Repo}/${params.Image} ."""
      }
    }

    stage('Push image to registry')  {
      steps {
        sh "docker push ${params.Repo}/${params.Image}"
      }
    }

    stage('Deploy') {
      steps {
        // sh "docker container stop ${params.Container} || true"
        // sh "docker container rm ${params.Container} || true"
        sh "kubectl apply -f k8s"
        // sh "docker run -d -p 3005:3005 --name ${params.Container} ${params.Repo}/${params.Image}"
        echo "Successfully build ${env.BUILD_ID} on ${env.JENKINS_URL}"
      }
    } 
  }
}
