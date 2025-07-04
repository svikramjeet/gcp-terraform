terraform { 
  cloud { 
    
    organization = "svikramjeet" 

    workspaces { 
      name = "test-rh" 
    } 
  } 
}