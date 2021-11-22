variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
}

variable "location" {
  default = "eastus2"
}


variable "tags" {
  type        = map(string)
  default = {
    udacity = "udacity-azure-project"
  }
}



variable "username" {
  description = "Enter username to associate with the machine"
  default     = "user"

}

variable "password" {
  description = "Enter password to use to access the machine"
  default     = "pwd"

}


