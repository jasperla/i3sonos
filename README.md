# i3sonos
i3status script for displaying current Sonos track

## Usage

In `~/.i3/config`:

```
bar {
	i3status | /path/to/i3sonos.rb
}
```

This will assume a speaker name is set in `~/.i3sonos.conf`, otherwise
it must be passed as an argument to `i3sonos.rb`.

### Configuration file

`~/.i3sonos.conf` is JSON file which has two fields:

```
{
	"enabled": true,
	"speaker": "office"
}
```

This file read at startup and changes to it are ignored once i3 is
running. To re-read the config file, restart i3.

## Roadmap

- Handle changing speakername in `i3sonos.conf`

## License

MIT, please see the LICENSE file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
