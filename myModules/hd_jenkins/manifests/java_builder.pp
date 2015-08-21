class hd_jenkins::java_builder {
# not all jenkins machines will need this stuff....
# this will default to gradle 2.1, have to use a different syntax to get it with other versions
# or set the values in hiera
  include hd_jenkins::build_tools::gradle
  include hd_jenkins::build_tools::maven

  #TODO: put other stuff in here that's java building specific
}