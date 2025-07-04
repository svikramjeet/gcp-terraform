terraform { 
  cloud { 
    
    organization = "svikramjeet" 

    workspaces { 
      name = "prod-rh" 
    } 
  } 
}