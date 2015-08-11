class hd_go_cd {
  include hd_go_cd::package

  #TODO: install the server somewhere, and the agent somewhere else
  firewall{ '100 gocd access':
    port   => [8154, 8153],
    proto  => tcp,
    action => accept,
  }
}