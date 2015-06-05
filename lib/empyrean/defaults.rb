module Empyrean
  # Application name
  APP_NAME = "Empyrean"

  # Version
  VERSION = "0.0.2"

  # Combined version string
  VERSION_STR = "#{APP_NAME} #{VERSION}"

  # Regexp for matching user names
  USERNAME_REGEX = /[@]([a-zA-Z0-9_]{1,16})/

  # Regexp for matching the client source
  SOURCE_REGEX = /^<a href=\"(https?:\/\/\S+|erased_\d+)\" rel=\"nofollow\">(.+)<\/a>$/

  # Regexp for matching hashtags
  HASHTAG_REGEX = /[#]([^{}\[\]().,\-:!*_?#\s]+)/
end
