# Devilicious

**Disclaimer: Do not expect to make money with this program.**

This RubyGem is just an experiment to find out whether or not there are (still) arbitrage opportunities across Bitcoin markets (as of August 2014).

Spoiler: Meh, not really.

Supported exchanges are:

- Kraken (EUR)
- BitcoinDe (EUR)
- BTCE (EUR)
- HitBTC (EUR)
- Bitcurex (EUR)
- Bitstamp (USD)
- BitNZ (NZD)
- ANXBTC (CHF)

I've been running it for a couple of days and my findings are:

- the best volume to trade is usually in the 1 to 5 bitcoins range
- you won't make more than €30/$40 even trading when the price is on a rollercoaster (specifically mid August 2014)
- you'll need to trade 3+ bitcoins to make those 40 bucks
- in order to trade across a bunch of markets, you'll need to have a lot of funds in every exchanges (since you want to buy/sell at the same time)
- high frequency trading might work out better but fuck that, it just adds noise to the blockchain

**Disclaimer #2: This code is quite crappy.**

This is a just-for-fun quick-and-dirty not-optimized-at-all pretty-dumb program.
Worst of all, it doesn't even have tests!

**Disclaimer #3: Obviously, use this program at your own risks!**

## Installation

`gem install devilicious`

## Usage

`devilicious --help` is your friend.

Example: `devilicious -f Table -m 2 -b 30`

## License

AGPLv3

## Bonus link

http://www.reddit.com/r/Bitcoin/comments/2dqhiy/8month_high/cjs416y

