class hd_gitlab {
  # gitlab needs sending
  include base::mail_sender

  #TODO: eventually we're going to want HTTPS. Maybe i'll just do a self-signed cert for now...
  include ssl_cert

  # get our package installed!
  include hd_gitlab::package

  #TODO: set up the rest of the stuff, backups?
  #what does the https/http port stuff look like?
  #TODO: centralized authentication?
}