terraform {
  cloud {

    organization = "svikramjeet"

    workspaces {
      name = "rh-prod"
    }
  }
}