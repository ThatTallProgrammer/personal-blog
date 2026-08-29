workspace "Blog" "v001" {

    model {
        u = person "User"
        s = softwareSystem "Software System" {
            webapp = container "Ghost" "" "Node.js"
            database = container "SQLite Database" "" "Relational database"
            reverseProxy = container "Nginx" "" "Reverse Proxy"
        }

        u -> webapp "Uses"
        webapp -> database "Reads from and writes to" "SQLite / filesystem"
        reverseProxy -> webapp "Forwards traffic to" "HTTPS"
        
        live = deploymentEnvironment "Live" {
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"
                
                deploymentNode "US-East-1" {
                    tags "Amazon Web Services - Region"
                
                    igw = infrastructureNode "Internet GW" {
                        tags "Amazon Web Services - VPC Internet Gateway"
                    }

                    deploymentNode "Amazon EC2" {
                        tags "Amazon Web Services - EC2"
                        
                        deploymentNode "Amazon Linux" {
                            reverseProxyInstance = containerInstance reverseProxy
                            webApplicationInstance = containerInstance webapp
                            sqlLiteDatabaseInstance = containerInstance database
                        }
                    }
                }
            }
            
            igw -> reverseProxyInstance "Forwards requests to" "HTTPS"
        }
    }

    views {
        deployment s live {
            include *
            autoLayout lr
        }

        theme https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }
    
}
