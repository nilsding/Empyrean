# RubyTwitterStats

Generate full stats of your account using your Twitter Archive.

**Pro Tip™:** move the *data/js/tweets* directory into the downloaded
RubyTwitterStats directory, so you just have to run `./stats.rb -d tweets`

## Usage

1. Download your Twitter archive and unpack it somewhere.
2. `./stats.rb -d path/to/data/js/tweets`
3. ???
4. Profit!

### But… I'm using Windows!

First of all, install [RubyInstaller][ri].  Ruby 1.9 is good to go.  Make sure
that Ruby is in your `$PATH`.

1. Install RubyInstaller and set its PATH (the installer should do that
   automatically)
2. Navigate to the RubyTwitterStats-directory and open a PowerShell or cmd in
   it.
3. `ruby ./stats.rb -d path/to/data/js/tweets`
4. ???
5. Profit!

## Configuration

Configuration is done using the `config.yml` file.  Rename
`config.yml.example` to `config.yml` to fit it your needs.

You can also use the `-C` flag to override config values on the fly, such as
`-C timezone_difference=2` or `-C mentions_enabled=no`.  If the configuration
variable is a list, seperate the elements with `,`.  For example, to ignore
the Twitter users `BarackObama` and `baddragon_en`, use
`-C ignored_users=BarackObama,baddragon_en`.

[ri]: http://rubyinstaller.org/ RubyInstaller