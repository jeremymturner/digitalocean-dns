digitalocean-dns
================

Ruby script to add common Google Apps DNS entries into DigitalOcean


Uses Trollop for command-line processing
http://trollop.rubyforge.org

## Usage
  * Add environment variables with your DigitalOcean keys:
```
export DO_CLIENT_ID=....DO CLIENT ID....
export DO_API_KEY=....API KEY....
```
You can get these keys from DigitalOcean under API:
https://cloud.digitalocean.com/api_access

  * Run the following command:
```
ruby add-domain.rb --domain example.com --ip 12.34.56.78
```
The command will return an error and the corresponding error message.
