# Tax Tribunals Fees

[![CircleCI](https://circleci.com/gh/ministryofjustice/tax-tribunals-fees.svg?style=svg&circle-token=53059f2bf1c3a736853b21bdb4ab3df9baf2dd2b)](https://circleci.com/gh/ministryofjustice/tax-tribunals-fees)

Ruby on Rails Web application to enable payments for Tax Tribunal fees.

## Setup & Run (locally)

This app uses [Docker Compose](https://docs.docker.com/compose/) to run locally, which lets you spin up an app container and a database with minimal effort:

```
# Set up environment variables
cp .env.example .env

# Create the database
docker-compose run web rails db:create db:migrate

# Run the containers
docker-compose up
```

### GOV.UK Pay API Key

In order to use GOV.UK Pay, you will need to configure your environment
with a sandbox API key – this can be obtained from the [GOV.UK Pay Self
Service](https://selfservice.pymnt.uk/) portal (although you will need
an account for this), and then set as `GOVUK_PAY_API_KEY` in the `.env`
file.

### Running the app directly on your machine

You are of course free to run the app directly too, in which case you
will need to bring your own Ruby-ready environment and PostgreSQL
server. You will also need to tweak the `DATABASE_URL` environment
variable in `.env`.

### .env.test

If you need a sensible `.env.test`, you can copy over the example from
`.env.test.example`.

### Environment Variables

`UPDATE_GLIMR=false`

Notifiy glimr of successful payments. If set to false, a case will not be
marked as paid when the payment is submitted. This is useful in development
mode when you want to continually re-submit the same claim.  Default is false
in development and true in production and test (where you want to mock the
api calls).

### Nokogiri installation issues on OSX

If you are trying to run the app directly on OSX 10.11 and nokogiri
1.6.8 will not install, run `xcode-select --install` and try again. The
issue is described [here][1].

[1]: https://github.com/sparklemotion/nokogiri/issues/1445
