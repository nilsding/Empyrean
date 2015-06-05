# Empyrean

Generate full stats of your account using your Twitter Archive.

## Usage

1. Install Empyrean using `gem install empyrean`
1. Download your Twitter archive and unpack it somewhere.
2. Generate a new configuration file: `empyrean -g config.yml`
2. `empyrean -d path/to/data/js/tweets`
3. ???
4. Profit!

## Configuration

Configuration is done using the `config.yml` file in the current directory.
You can generate one using `empyrean -g config.yml`.  You may also specify a
different configuration file to use with the `-c` switch.

You can also use the `-C` switch to override config values on the fly, such as
`-C timezone_difference=2` or `-C mentions_enabled=no`.  If the configuration
variable is a list, separate the elements with `,`.  For example, to ignore
the Twitter users `BarackObama` and `baddragon_en`, use
`-C ignored_users=BarackObama,baddragon_en`.

