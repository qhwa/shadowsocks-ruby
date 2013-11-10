shadowsocks-ruby
================

[![Code Climate](https://codeclimate.com/repos/524baea6c7f3a37df208dd4c/badges/9dd6c11b6a17c3a55631/gpa.png)](https://codeclimate.com/repos/524baea6c7f3a37df208dd4c/feed)

Current version: 0.6

shadowsocks-ruby is a lightweight tunnel proxy which can help you get through firewalls. It is a port of [shadowsocks](https://github.com/clowwindy/shadowsocks).

Usage
-----------

First, make sure you have Ruby 2.0.

    $ ruby -v
    ruby 2.0.0p247

Install Shadowsocks.

    gem install shadowsocks

Create a file named `config.json`, with the following content.

    {
        "server":"my_server_ip",
        "server_port":8388,
        "local_port":1080,
        "password":"barfoo!",
        "timeout":60,
        "method":"aes-128-cfb"
    }

Explanation of the fields:

    server          your server IP (IPv4/IPv6), notice that your server will listen to this IP
    server_port     server port
    local_port      local port
    password        a password used to encrypt transfer
    timeout         in seconds
    method          encryption method, "bf-cfb", "aes-256-cfb", "des-cfb", "rc4", etc. Default is "aes-128-cfb"
    
`cd` into the directory of `config.json`. Run `ss-server` on your server. To run it in the background, run
`nohup ss-server -c ./config.json > log &`.

On your client machine, `cd` into the directory of `config.json` also, run `ss-local -c config.json`.

Change the proxy settings in your browser to

    protocol: socks5
    hostname: 127.0.0.1
    port:     your local_port

It's recommended to use shadowsocks with AutoProxy or Proxy SwitchySharp.

Command line args
------------------

You can use args to override settings from `config.json`.

    ss-local -s server_name -p server_port -l local_port -k password
    ss-server -p server_port -k password
    ss-server -c /etc/shadowsocks/config.json

License
-------
MIT

Bugs and Issues
----------------
Please visit [issue tracker](https://github.com/Sen/shadowsocks-ruby/issues?state=open)
